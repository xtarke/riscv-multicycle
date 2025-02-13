library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cordic_core is
    generic(
        N_ITER     : integer := 16;     -- must be pair
        DATA_WIDTH : integer := 16;
        ANGLE_BITS : integer := 14
    );
    port(
        clk_bus  : in  std_logic;
        rst_bus  : in  std_logic;
        start    : in  std_logic;
        angle_in : in  signed(DATA_WIDTH-1 downto 0);
        sin_out  : out signed(DATA_WIDTH-1 downto 0);
        cos_out  : out signed(DATA_WIDTH-1 downto 0);
        valid    : out std_logic
    );
end cordic_core;

architecture Behavioral of cordic_core is
    type state_type is (IDLE, PROCESSING, DONE);
    signal state : state_type := IDLE;
    
    type angle_table is array (0 to 15) of signed(DATA_WIDTH-1 downto 0);
    constant angles : angle_table := (
        x"3243", x"1DAC", x"0FAD", x"07F5",
        x"03FF", x"0200", x"0100", x"0080",
        x"0040", x"0020", x"0010", x"0008",
        x"0004", x"0002", x"0001", x"0000"
    );

    signal x_reg, y_reg, z_reg : signed(DATA_WIDTH-1 downto 0);
    signal iteration : integer range 0 to N_ITER := 0;
    
begin
    process(clk, rst)
        variable x1, y1, z1 : signed(DATA_WIDTH-1 downto 0);
        variable x2, y2, z2 : signed(DATA_WIDTH-1 downto 0);
    begin
        if rst = '1' then
            state <= IDLE;
            valid <= '0';
            x_reg <= (others => '0');
            y_reg <= (others => '0');
            z_reg <= (others => '0');
            iteration <= 0;
        else
            if rising_edge(clk) then
                case state is
                    when IDLE =>
                        valid <= '0';
                        if start = '1' then
                            x_reg <= to_signed(integer(0.60725 * 2**ANGLE_BITS), DATA_WIDTH);
                            y_reg <= (others => '0');
                            z_reg <= angle_in;
                            iteration <= 0;
                            state <= PROCESSING;
                        end if;

                    when PROCESSING =>
                        if iteration < N_ITER then
                            -- first iteration (i)
                            if z_reg >= 0 then
                                x1 := x_reg - shift_right(y_reg, iteration);
                                y1 := y_reg + shift_right(x_reg, iteration);
                                z1 := z_reg - angles(iteration);
                            else
                                x1 := x_reg + shift_right(y_reg, iteration);
                                y1 := y_reg - shift_right(x_reg, iteration);
                                z1 := z_reg + angles(iteration);
                            end if;
                            
                            -- second iteration (i+1)
                            if z1 >= 0 then
                                x2 := x1 - shift_right(y1, iteration+1);
                                y2 := y1 + shift_right(x1, iteration+1);
                                z2 := z1 - angles(iteration+1);
                            else
                                x2 := x1 + shift_right(y1, iteration+1);
                                y2 := y1 - shift_right(x1, iteration+1);
                                z2 := z1 + angles(iteration+1);
                            end if;
                            
                            -- update regs
                            x_reg <= x2;
                            y_reg <= y2;
                            z_reg <= z2;
                            iteration <= iteration + 2;
                        else
                            state <= DONE;
                        end if;
                        
                    when DONE =>
                        sin_out <= y_reg;
                        cos_out <= x_reg;
                        valid <= '1';
                        state <= IDLE;
                end case;
            end if;
        end if;
    end process;
end Behavioral;

-- exemplo no quartus
-- signal cordic_x_out, cordic_y_out : std_logic_vector(15 downto 0);
-- signal cordic_angle, cordic_x_in, cordic_y_in : std_logic_vector(15 downto 0);
-- signal cordic_clk, cordic_rst : std_logic;

-- begin
--     cordic_inst : entity work.cordic
--         port map (
--             clk     => cordic_clk,
--             rst     => cordic_rst,
--             x_in    => cordic_x_in,
--             y_in    => cordic_y_in,
--             angle   => cordic_angle,
--             x_out   => cordic_x_out,
--             y_out   => cordic_y_out
--         );
