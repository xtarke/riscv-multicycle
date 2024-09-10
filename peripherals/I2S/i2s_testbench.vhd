library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity test_bench is
end test_bench;

architecture Test of test_bench is
    signal clk_tb : std_logic;
    signal sck_tb : std_logic;
    signal rst_tb : std_logic;
    signal ws_tb : std_logic;
    signal sd_tb : std_logic;
    signal enable_tb : std_logic;
    signal left_channel_tb : std_logic_vector(31 downto 0);
    signal right_channel_tb : std_logic_vector(31 downto 0);
    signal q_tb: std_logic_vector(31 downto 0);
    

    begin
        I2S_inst : entity work.I2S
            port map(
                clk           => clk_tb,
                sck           => sck_tb,
                rst           => rst_tb,
                ws            => ws_tb,
                sd            => sd_tb,
                enable        => enable_tb,
                left_channel  => left_channel_tb,
                right_channel => right_channel_tb
            );

        men_cycle_inst : entity work.men_cycle
            port map(
                clk  => clk_tb,
                rst  => rst_tb,
                data => right_channel_tb,
                wren  => ws_tb,
                q    => q_tb
            );
        
        clock_driver : process
            constant period : time := 10 ns;
        begin
            clk_tb <= '1';
            wait for period / 2;
            clk_tb <= '0';
            wait for period / 2;
        end process clock_driver;
        
        rst : process is
        begin
            rst_tb <= '1';
            wait for 2 ns;
            rst_tb <= '0';
            wait;
        end process rst;
        
        sign : process is                                                                -------
            constant data_1 : std_logic_vector(31 downto 0) := "00110001010010101100100110011010";
            constant data_2 : std_logic_vector(31 downto 0) := "01000100011100001111001000101101";
            variable i : integer;
            
        begin      
            enable_tb <= '1';
            sd_tb <= '0';

            i := 31;
            while i /= -1 loop
                wait until sck_tb = '0'; 
                sd_tb <= data_1(i);
                i := i - 1;         
            end loop;

            i := 31;
            while i /= -1 loop
                wait until sck_tb = '0'; 
                sd_tb <= data_2(i);
                i := i - 1;         
            end loop;

            i := 31;
            while i /= -1 loop
                wait until sck_tb = '0'; 
                sd_tb <= data_1(i);
                i := i - 1;         
            end loop;


        end process sign;
        
end architecture Test;
