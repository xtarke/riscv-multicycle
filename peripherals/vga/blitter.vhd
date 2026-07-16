--------------------------------------------------------------------------------
--  2D blitter -- command-driven accelerator
--------------------------------------------------------------------------------
--
-- Departamento de Eletronica, Florianopolis, IFSC
--
-- The CPU stages a command in a small register block and writes CMD; that
-- snapshots the registers into ONE wide fifo entry (whole command per entry).
-- BLIT_IDLE just checks the fifo and DISPATCHES to a per-opcode state; each
-- opcode's state reads the fields it needs from the latched command
-- (active_command) via the named views (arg_*) below. Adding a primitive = one
-- dispatch line + its state(s). Writes go to the SAME port the CPU uses (muxed
-- at the top level) and are throttled on write_busy.
--
-- OPCODES  (command byte [7:0]; [15:8] = per-opcode flags)
--   0x01  OP_FILL    filled rectangle        -- implemented
--   0x02  OP_LINE    Bresenham line          -- implemented
--
--
--     OP_FILL:  P0=x   P1=y   P2=w   P3=h    color
--     OP_LINE:  P0=x0  P1=y0  P2=x1  P3=y1   color
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
  constant OP_LINE : std_logic_vector(7 downto 0) := x"02";

  type blit_state_t is (
    BLIT_IDLE,
    BLIT_FILL_INIT,
    BLIT_FILL,
    BLIT_LINE_INIT,
    BLIT_LINE
  );
  signal blit_state : blit_state_t;

  -- Command register block: staged by the CPU, snapshot on the CMD trigger --
  signal p0_reg, p1_reg, p2_reg, p3_reg : std_logic_vector(15 downto 0);
  signal p4_reg, p5_reg                 : std_logic_vector(15 downto 0);
  signal color_reg                      : std_logic_vector(15 downto 0);
  signal op_reg                         : std_logic_vector(15 downto 0);

  -- Command fifo: one whole command per 128-bit entry
  signal cmd_fifo_data  : std_logic_vector(127 downto 0);
  signal cmd_fifo_head  : std_logic_vector(127 downto 0);
  signal cmd_fifo_push  : std_logic;
  signal cmd_fifo_pop   : std_logic;
  signal cmd_fifo_empty : std_logic;
  signal cmd_fifo_full  : std_logic;

  -- Latched command being executed, and named views of the packed layout --
  signal active_command : std_logic_vector(127 downto 0);
  signal arg_x          : unsigned(15 downto 0);            -- P0
  signal arg_y          : unsigned(15 downto 0);            -- P1
  signal arg_w          : unsigned(15 downto 0);            -- P2 (fill w)
  signal arg_h          : unsigned(15 downto 0);            -- P3 (fill h)
  signal arg_x1         : unsigned(15 downto 0);            -- P2 (line end x)
  signal arg_y1         : unsigned(15 downto 0);            -- P3 (line end y)
  signal arg_color      : std_logic_vector(15 downto 0);

  -- Fill pixel walker --
  signal fill_col       : natural range 0 to 65535;        -- column within the rect
  signal fill_row       : natural range 0 to 65535;        -- row within the rect
  signal fill_row_addr  : natural range 0 to 2**26 - 1;    -- address of (x, y+row)
  signal fill_addr      : natural range 0 to 2**26 - 1;    -- current pixel address

  -- Line walker (Bresenham) --
  signal line_x         : integer range 0 to 65535;        -- current point x
  signal line_y         : integer range 0 to 65535;        -- current point y
  signal line_end_x     : integer range 0 to 65535;        -- end point x
  signal line_end_y     : integer range 0 to 65535;        -- end point y
  signal line_delta_x   : integer range 0 to 65535;        -- |x1-x0|
  signal line_delta_y   : integer range -65535 to 0;       -- -|y1-y0|
  signal line_step_x    : integer range -1 to 1;           -- x step (+/-1)
  signal line_step_y    : integer range -1 to 1;           -- y step (+/-1)
  signal line_error     : integer range -131072 to 131072;

begin

  cmd : entity work.fifo_128
    port map (
      clock       => clk,
      sclr        => reset,
      data        => cmd_fifo_data,
      wrreq       => cmd_fifo_push,
      rdreq       => cmd_fifo_pop,
      q           => cmd_fifo_head,
      empty       => cmd_fifo_empty,
      full        => cmd_fifo_full,
      almost_full => open,
      usedw       => open
    );

  cmd_fifo_data <= color_reg & p5_reg & p4_reg & p3_reg & p2_reg & p1_reg & p0_reg & op_reg;
  busy          <= '0' when blit_state = BLIT_IDLE and cmd_fifo_empty = '1' else '1';

  -- Named views of the latched command layout, for the execution states --
  arg_x     <= unsigned(active_command(31 downto 16));
  arg_y     <= unsigned(active_command(47 downto 32));
  arg_w     <= unsigned(active_command(63 downto 48));
  arg_h     <= unsigned(active_command(79 downto 64));
  arg_x1    <= unsigned(active_command(63 downto 48));
  arg_y1    <= unsigned(active_command(79 downto 64));
  arg_color <= active_command(127 downto 112);

  -- Pop the head the cycle we dispatch it (show-ahead: cmd_fifo_head is the head) --
  cmd_fifo_pop <= '1' when blit_state = BLIT_IDLE and cmd_fifo_empty = '0' else '0';

  process (clk, reset)
  begin
    if reset = '1' then
      p0_reg <= (others => '0'); p1_reg <= (others => '0');
      p2_reg <= (others => '0'); p3_reg <= (others => '0');
      p4_reg <= (others => '0'); p5_reg <= (others => '0');
      color_reg <= (others => '0'); op_reg <= (others => '0');
      cmd_fifo_push <= '0';
    elsif rising_edge(clk) then
      cmd_fifo_push <= '0';
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
              cmd_fifo_push <= '1';
        end case;
      end if;
    end if;
  end process;

  -- Blitter FSM --
  process (clk, reset)
    variable delta_x       : integer range 0 to 65535;      -- |x1-x0|
    variable delta_y       : integer range -65535 to 0;     -- -|y1-y0|
    variable doubled_error : integer range -262144 to 262144;
    variable next_error    : integer range -131072 to 131072;
  begin
    if reset = '1' then
      blit_state    <= BLIT_IDLE;
      active_command         <= (others => '0');
      write_commit  <= '0';
      write_address <= (others => '0');
      write_data    <= (others => '0');
      fill_col <= 0; fill_row <= 0;
      fill_row_addr <= 0; fill_addr <= 0;
    elsif rising_edge(clk) then
      write_commit <= '0';

      case blit_state is
        when BLIT_IDLE =>
          if cmd_fifo_empty = '0' then
            active_command <= cmd_fifo_head;
            case cmd_fifo_head(7 downto 0) is
              when OP_FILL =>
          blit_state <= BLIT_FILL_INIT;
              when OP_LINE =>
          blit_state <= BLIT_LINE_INIT;
              when others  =>
          -- unknown opcode: consumed, stay idle
          null;
        end case;
          end if;
        when BLIT_FILL_INIT =>
          fill_col    <= 0;
          fill_row    <= 0;
          fill_row_addr <= to_integer(arg_y) * SCREEN_W + to_integer(arg_x);
          fill_addr <= to_integer(arg_y) * SCREEN_W + to_integer(arg_x);
          if arg_w /= 0 and arg_h /= 0 then
            blit_state <= BLIT_FILL;
          else
            blit_state <= BLIT_IDLE;        -- empty rectangle
          end if;

        -- FILL_RECT: one write per pixel while the write fifo has room --
        when BLIT_FILL =>
          if write_busy = '0' then
            write_commit  <= '1';
            write_address <= std_logic_vector(to_unsigned(fill_addr, 32));
            write_data    <= arg_color;
            if fill_col = to_integer(arg_w) - 1 then
              fill_col <= 0;
              if fill_row = to_integer(arg_h) - 1 then
                blit_state <= BLIT_IDLE;    -- rectangle done
              else
                fill_row    <= fill_row + 1;
                fill_row_addr <= fill_row_addr + SCREEN_W;
                fill_addr <= fill_row_addr + SCREEN_W;
              end if;
            else
              fill_col    <= fill_col + 1;
              fill_addr <= fill_addr + 1;
            end if;
          end if;

        -- LINE (Bresenham): P0,P1 = start, P2,P3 = end --
        when BLIT_LINE_INIT =>
          delta_x    := abs(to_integer(arg_x1) - to_integer(arg_x));
          delta_y    := -abs(to_integer(arg_y1) - to_integer(arg_y));
          line_x   <= to_integer(arg_x);
          line_y   <= to_integer(arg_y);
          line_end_x  <= to_integer(arg_x1);
          line_end_y  <= to_integer(arg_y1);
          line_delta_x  <= delta_x;
          line_delta_y  <= delta_y;
          line_error <= delta_x + delta_y;
          if arg_x1 >= arg_x then line_step_x <= 1; else line_step_x <= -1; end if;
          if arg_y1 >= arg_y then line_step_y <= 1; else line_step_y <= -1; end if;
          blit_state <= BLIT_LINE;

        -- LINE: one write per pixel, then the Bresenham step (throttled) --
        when BLIT_LINE =>
          if write_busy = '0' then
            write_commit  <= '1';
            write_address <= std_logic_vector(to_unsigned(line_y * SCREEN_W + line_x, 32));
            write_data    <= arg_color;
            if line_x = line_end_x and line_y = line_end_y then
              blit_state <= BLIT_IDLE;      -- last pixel plotted
            else
              doubled_error   := 2 * line_error;
              next_error := line_error;
              if doubled_error >= line_delta_y then
                next_error := next_error + line_delta_y;
                line_x <= line_x + line_step_x;
              end if;
              if doubled_error <= line_delta_x then
                next_error := next_error + line_delta_x;
                line_y <= line_y + line_step_y;
              end if;
              line_error <= next_error;
            end if;
          end if;

      end case;
    end if;
  end process;

end architecture blitter_behavior;
