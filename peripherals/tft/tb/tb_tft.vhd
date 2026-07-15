--No código de inicialização do display há delays de inicialização em milisegundos, 
--para conseguir aferir o funcionamento na simulação, é recomendado que altere o
--valor da constante ADJ presente no arquivo "writer.vhd" para o valor 1.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-------------------------------------
entity testbench_tft_controller is
end entity testbench_tft_controller;
------------------------------

architecture stimulus_tft_controller of testbench_tft_controller is

	signal clk        : std_logic;
	signal daddress   : unsigned(31 downto 0);
	signal ddata_w    : std_logic_vector(31 downto 0);
	signal ddata_r    : std_logic_vector(31 downto 0);
	signal d_we       : std_logic;
	signal d_rd       : std_logic;
	signal dcsel      : std_logic_vector(1 downto 0);
	signal ret        : unsigned(31 downto 0);
	signal pin_output : unsigned(7 downto 0);
	signal pin_cs     : std_logic;
	signal pin_rs     : std_logic;
	signal pin_wr     : std_logic;
	signal pin_rst    : std_logic;

begin

	tft_inst : entity work.tft
		generic map(
			MY_CHIPSELECT     => "10",
			MY_WORD_ADDRESS   => x"0000",
			DADDRESS_BUS_SIZE => 32
		)
		port map(
			clk        => clk,
			daddress   => daddress,
			ddata_w    => ddata_w,
			ddata_r    => ddata_r,
			d_we       => d_we,
			d_rd       => d_rd,
			dcsel      => dcsel,
			ret        => ret,
			pin_output => pin_output,
			pin_cs     => pin_cs,
			pin_rs     => pin_rs,
			pin_wr     => pin_wr,
			pin_rst    => pin_rst
		);


	clock : process
	begin
		clk <= '0';
		wait for 1 ns;
		clk <= '1';
		wait for 1 ns;
	end process;

	process
	begin
		dcsel <= "10";
		d_we <= '1';
		
		daddress <= x"00000000";
		ddata_w <= x"ffffffff";
		wait for 10 ns;
		
		daddress <= (x"00000000" + 1);
		ddata_w <= x"00000000";
		wait for 10 ns;
		
		daddress <= (x"00000000" + 2);
		ddata_w <= x"00000000";
		
		wait for 20 us;
		
		d_we <= '0';
		wait for 10 ns;
	
		d_we <= '1';

		daddress <= x"00000000";
		ddata_w <= x"0001fafa";
		wait for 10 ns;
		
		daddress <= (x"00000000" + 1);
		ddata_w <= x"00000000";
		wait for 10 ns;
		
		daddress <= (x"00000000" + 2);
		ddata_w <= x"00000000";
		wait for 100 ns;
		
		d_we <= '0';
		wait for 10 ns;
	
		d_we <= '1';

		daddress <= x"00000000";
		ddata_w <= x"0003ffff";
		wait for 10 ns;
		
		daddress <= (x"00000000" + 1);
		ddata_w <= x"00020002";
		wait for 10 ns;
		
		daddress <= (x"00000000" + 2);
		ddata_w <= x"00020002";
		wait;
	end process;

end architecture stimulus_tft_controller;
