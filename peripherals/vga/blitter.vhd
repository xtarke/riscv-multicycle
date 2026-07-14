--------------------------------------------------------------------------------
--  2D blitter -- command-driven accelerator (fill-rect; extensible to line,
--  circle, triangle, sprite by adding opcodes)
--------------------------------------------------------------------------------
--
-- Departamento de Eletronica, Florianopolis, IFSC
--
-- The CPU stages a command in a small register block and writes CMD; that
-- snapshots the registers into ONE wide fifo entry (whole command per entry).
-- BLIT_IDLE just checks the fifo and DISPATCHES to a per-opcode state; each
-- opcode's state reads the fields it needs from the latched command (cmd_r) via
-- the named field views below. Adding a primitive = one dispatch line + its
-- state(s). Writes go to the SAME port the CPU uses (muxed at the top level).
--
-- Packed command word (128-bit fifo entry, fields reused per opcode):
--   [15:0] opcode|flags   [31:16] P0   [47:32] P1   [63:48] P2
--   [79:64] P3   [95:80] P4   [111:96] P5   [127:112] color
--   FILL_RECT: P0=x P1=y P2=w P3=h
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity blitter is
  generic (
    SCREEN_W : natural := 640
  );
  port (
    clk   : in std_logic;
    reset : in std_logic;

    reg_we   : in std_logic;
    reg_addr : in std_logic_vector(2 downto 0);
    reg_data : in std_logic_vector(31 downto 0);

    busy : out std_logic;

    write_commit  : out std_logic;
    write_address : out std_logic_vector(31 downto 0);
    write_data    : out std_logic_vector(15 downto 0);
    write_busy    : in  std_logic
  );
end entity blitter;

architecture blitter_behavior of blitter is

  constant OP_FILL : std_logic_vector(7 downto 0) := x"01";

  type blit_state_t is (BLIT_IDLE, BLIT_FILL_INIT, BLIT_FILL);
  signal blit_state : blit_state_t;

  -- Command register block: staged by the CPU, snapshot on the CMD trigger --
  signal p0_reg, p1_reg, p2_reg, p3_reg : std_logic_vector(15 downto 0);
  signal p4_reg, p5_reg                 : std_logic_vector(15 downto 0);
  signal color_reg                      : std_logic_vector(15 downto 0);
  signal op_reg                         : std_logic_vector(15 downto 0);

  -- Command fifo: one whole command per 128-bit entry
  signal cmd_din   : std_logic_vector(127 downto 0);
  signal cmd_q     : std_logic_vector(127 downto 0);
  signal cmd_wr    : std_logic;
  signal cmd_rd    : std_logic;
  signal cmd_empty : std_logic;
  signal cmd_full  : std_logic;

  -- Latched command being executed, and named views of the packed layout --
  signal cmd_r   : std_logic_vector(127 downto 0);
  signal f_x     : unsigned(15 downto 0);   -- P0
  signal f_y     : unsigned(15 downto 0);   -- P1
  signal f_w     : unsigned(15 downto 0);   -- P2
  signal f_h     : unsigned(15 downto 0);   -- P3
  signal f_color : std_logic_vector(15 downto 0);

  -- Pixel walker --
  signal i_cnt    : natural range 0 to 65535;        -- column within the rect
  signal j_cnt    : natural range 0 to 65535;        -- row within the rect
  signal row_base : natural range 0 to 2**26 - 1;    -- address of (x, y+j)
  signal cur_addr : natural range 0 to 2**26 - 1;    -- current pixel address

begin

  cmd : entity work.fifo_128
    port map (
      clock       => clk,
      sclr        => reset,
      data        => cmd_din,
      wrreq       => cmd_wr,
      rdreq       => cmd_rd,
      q           => cmd_q,
      empty       => cmd_empty,
      full        => cmd_full,
      almost_full => open,
      usedw       => open
    );

  cmd_din <= color_reg & p5_reg & p4_reg & p3_reg & p2_reg & p1_reg & p0_reg & op_reg;
  busy    <= '0' when blit_state = BLIT_IDLE and cmd_empty = '1' else '1';

  -- Named views of the latched command layout, for the execution states --
  f_x     <= unsigned(cmd_r(31 downto 16));
  f_y     <= unsigned(cmd_r(47 downto 32));
  f_w     <= unsigned(cmd_r(63 downto 48));
  f_h     <= unsigned(cmd_r(79 downto 64));
  f_color <= cmd_r(127 downto 112);

  -- Pop the head the cycle we dispatch it (show-ahead: cmd_q is the head) --
  cmd_rd <= '1' when blit_state = BLIT_IDLE and cmd_empty = '0' else '0';

  process (clk, reset)
  begin
    if reset = '1' then
      p0_reg <= (others => '0'); p1_reg <= (others => '0');
      p2_reg <= (others => '0'); p3_reg <= (others => '0');
      p4_reg <= (others => '0'); p5_reg <= (others => '0');
      color_reg <= (others => '0'); op_reg <= (others => '0');
      cmd_wr <= '0';
    elsif rising_edge(clk) then
      cmd_wr <= '0';
      if reg_we = '1' then
        case reg_addr is
          when "000"  => 
			  p0_reg <= reg_data(15 downto 0);
          when "001"  =>
			  p1_reg <= reg_data(15 downto 0);
          when "010"  =>
			  p2_reg <= reg_data(15 downto 0);
          when "011"  =>
			  p3_reg <= reg_data(15 downto 0);
          when "100"  =>
			  p4_reg <= reg_data(15 downto 0);
          when "101"  =>
			  p5_reg <= reg_data(15 downto 0);
          when "110"  => 
			  color_reg <= reg_data(15 downto 0);
          when others => 
			  op_reg <= reg_data(15 downto 0);
              cmd_wr <= '1';
        end case;
      end if;
    end if;
  end process;

  -- Blitter FSM --
  process (clk, reset)
  begin
    if reset = '1' then
      blit_state    <= BLIT_IDLE;
      cmd_r         <= (others => '0');
      write_commit  <= '0';
      write_address <= (others => '0');
      write_data    <= (others => '0');
      i_cnt <= 0; j_cnt <= 0;
      row_base <= 0; cur_addr <= 0;
    elsif rising_edge(clk) then
      write_commit <= '0';

      case blit_state is
        when BLIT_IDLE =>
          if cmd_empty = '0' then
            cmd_r <= cmd_q;
            case cmd_q(7 downto 0) is
              when OP_FILL => blit_state <= BLIT_FILL_INIT;
              when others  => null;         -- unknown opcode: consumed, stay idle
            end case;
          end if;
        when BLIT_FILL_INIT =>
          i_cnt    <= 0;
          j_cnt    <= 0;
          row_base <= to_integer(f_y) * SCREEN_W + to_integer(f_x);
          cur_addr <= to_integer(f_y) * SCREEN_W + to_integer(f_x);
          if f_w /= 0 and f_h /= 0 then
            blit_state <= BLIT_FILL;
          else
            blit_state <= BLIT_IDLE;        -- empty rectangle
          end if;

        -- FILL_RECT: one write per pixel while the write fifo has room --
        when BLIT_FILL =>
          if write_busy = '0' then
            write_commit  <= '1';
            write_address <= std_logic_vector(to_unsigned(cur_addr, 32));
            write_data    <= f_color;
            if i_cnt = to_integer(f_w) - 1 then
              i_cnt <= 0;
              if j_cnt = to_integer(f_h) - 1 then
                blit_state <= BLIT_IDLE;    -- rectangle done
              else
                j_cnt    <= j_cnt + 1;
                row_base <= row_base + SCREEN_W;
                cur_addr <= row_base + SCREEN_W;
              end if;
            else
              i_cnt    <= i_cnt + 1;
              cur_addr <= cur_addr + 1;
            end if;
          end if;

      end case;
    end if;
  end process;

end architecture blitter_behavior;
