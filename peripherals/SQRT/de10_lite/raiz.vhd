-------------------------------------------------------
-- IFSC
-- Sofia Maia Lee e Ueslei Marian
-- Projeto Final - Implementação de periferico que faz raiz quadrada
-------------------------------------------------------
--Bibliotecas padrão
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity raiz is
	generic (
		-- Chip select
		MY_CHIPSELECT : std_logic_vector(1 downto 0) := "10";
		MY_WORD_ADDRESS : unsigned(15 downto 0) := x"0019";
		DADDRESS_BUS_SIZE : integer := 32
	);

	port (
		clk : in std_logic;
		rst : in std_logic;

		-- Core data bus signals
		daddress : in  unsigned(DADDRESS_BUS_SIZE-1 downto 0);
		ddata_w  : in  std_logic_vector(31 downto 0);
		ddata_r  : out std_logic_vector(31 downto 0);
		d_we     : in  std_logic;
		d_rd     : in  std_logic;
		dcsel    : in  std_logic_vector(1 downto 0); --! Chip select 
        -- ToDo: Module should mask bytes (Word, half word and byte access)
		dmask    : in  std_logic_vector(3 downto 0); --! Byte enable mask

		-- hardware input/output signals
		switches : in std_logic_vector(9 downto 0)
	);
end entity raiz;

architecture RTL of raiz is

	-- Registradores para sincronizar as chaves com o clock 
	signal switches_sync_0 : std_logic_vector(9 downto 0);
	signal switches_sync_1 : std_logic_vector(9 downto 0);

	-- Saídas do IP ALTSQRT
	signal sqrt_q         : std_logic_vector(4 downto 0);
	signal sqrt_remainder : std_logic_vector(5 downto 0);

begin


	process(clk, rst)
	begin
		if rst = '1' then
			switches_sync_0 <= (others => '0');
			switches_sync_1 <= (others => '0');

		elsif rising_edge(clk) then
			switches_sync_0 <= switches;
			switches_sync_1 <= switches_sync_0;
		end if;
	end process;

	-- Instância do IP ALTSQRT gerado pelo Quartus
	sqrt_inst : entity work.sqrt
		port map (
			radical   => switches_sync_1,
			q         => sqrt_q,
			remainder => sqrt_remainder
		);

	-- Leitura do periférico pelo softcore
	process(clk, rst)
	begin
		if rst = '1' then
			ddata_r <= (others => '0');

		elsif rising_edge(clk) then
			if (d_rd = '1') and (dcsel = MY_CHIPSELECT) then

				if daddress(15 downto 0) = MY_WORD_ADDRESS then-- MY_WORD_ADDRESS + 0: valor das chaves

					-- Leitura do valor de entrada SW[9:0]
					ddata_r <= (31 downto 10 => '0') & switches_sync_1;

				elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + 1) then -- MY_WORD_ADDRESS + 1: resultado da raiz

					-- Leitura do resultado da raiz quadrada
					ddata_r <= (31 downto 5 => '0') & sqrt_q;

				elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + 2) then -- MY_WORD_ADDRESS + 2: resto

					-- Leitura do resto da operação
					ddata_r <= (31 downto 6 => '0') & sqrt_remainder;

				else
					ddata_r <= (others => '0');

				end if;
			end if;
		end if;
	end process;

end architecture RTL;