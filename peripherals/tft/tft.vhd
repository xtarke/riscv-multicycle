library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tft is
	generic (
			MY_CHIPSELECT : std_logic_vector(1 downto 0) := "10";
			MY_WORD_ADDRESS : unsigned(15 downto 0) := x"0000";	
			DADDRESS_BUS_SIZE : integer := 32
		);
	port(
		clk        : in  std_logic;
		
		-- Core data bus signals
		daddress  : in  unsigned(DADDRESS_BUS_SIZE-1 downto 0);
		ddata_w   : in  std_logic_vector(31 downto 0);  -- Substituir input_a, input_b, etc (se aplicável)
		ddata_r   : out std_logic_vector(31 downto 0);
		d_we      : in  std_logic;
		d_rd      : in  std_logic;
		dcsel     : in  std_logic_vector(1 downto 0);
		
		ret        : out unsigned(31 downto 0);
		pin_output : out unsigned(7 downto 0);
		pin_cs     : out std_logic;
		pin_rs     : out std_logic;
		pin_wr     : out std_logic;
		pin_rst    : out std_logic
	);
end entity;

architecture rtl_tft of tft is

	signal reset : std_logic;

	signal rd_en_boot_mem   : std_logic;
	signal rd_data_boot_mem : unsigned(31 downto 0);
	signal empty_boot_mem   : std_logic;

	signal wr_en_data_mem   : std_logic;
	signal wr_data_data_mem : unsigned(31 downto 0);
	signal rd_en_data_mem   : std_logic;
	signal rd_data_data_mem : unsigned(31 downto 0);
	signal empty_data_mem   : std_logic;
	signal full_data_mem    : std_logic;

	signal start : std_logic;
	signal ready : std_logic;

	signal mux_sel : std_logic;
	signal mux_out : unsigned(31 downto 0);
	
	signal reg_input_a : unsigned(31 downto 0) := (others => '0');
	signal reg_input_b : unsigned(31 downto 0) := (others => '0');
	signal reg_input_c : unsigned(31 downto 0) := (others => '0');
	signal start_sig   : std_logic := '0';
	
begin
	pin_rst <= not reset;

	mux32_inst : entity work.mux32
		port map(
			input_a => rd_data_boot_mem,
			input_b => rd_data_data_mem,
			sel     => mux_sel,
			output  => mux_out
		);

	boot_mem_inst : entity work.boot_mem
		port map(
			clk     => clk,
			rst     => reset,
			rd_en   => rd_en_boot_mem,
			rd_data => rd_data_boot_mem,
			empty   => empty_boot_mem
		);

	data_mem_inst : entity work.data_mem
		generic map(
			RAM_WIDTH => 32,
			RAM_DEPTH => 512,
			HEAD_INIT => 0
		)
		port map(
			clk     => clk,
			rst     => reset,
			wr_en   => wr_en_data_mem,
			wr_data => wr_data_data_mem,
			rd_en   => rd_en_data_mem,
			rd_data => rd_data_data_mem,
			empty   => empty_data_mem,
			full    => full_data_mem
		);

	write_cdmdata_inst : entity work.writer
		port map(
			clk    => clk,
			reset  => reset,
			start  => start,
			ready  => ready,
			input  => mux_out,
			output => pin_output,
			cs     => pin_cs,
			rs     => pin_rs,
			wr     => pin_wr
		);

	fsm_inst : entity work.controller
		port map(
			clk      => clk,
			reset    => reset,
			ready    => ready,
			start    => start,
			mux_sel  => mux_sel,
			empty_1  => empty_boot_mem,
			empty_2  => empty_data_mem,
			read_en1 => rd_en_boot_mem,
			read_en2 => rd_en_data_mem
		);

	decoder_inst : entity work.decoder_tft
			port map(
				clk      => clk,
				mem_init => empty_boot_mem,
				mem_full => full_data_mem,
				start    => start_sig, -- Novo sinalizador
				input_a  => reg_input_a,
				input_b  => reg_input_b,
				input_c  => reg_input_c,
				output   => wr_data_data_mem,
				enable   => wr_en_data_mem,
				rst      => reset
			);
		
	-- Processo de escrita nos registradores do TFT (baseado no GPIO)
    process(clk, reset)
    begin
        if reset = '1' then
            reg_input_a <= (others => '0');
            reg_input_b <= (others => '0');
            reg_input_c <= (others => '0');
            start_sig   <= '0';
        elsif rising_edge(clk) then
            start_sig <= '0';
            
            if (d_we = '1') and (dcsel = MY_CHIPSELECT) then
                -- Endereço Base (Offset + 0 palavras) -> Mapeia o TFT_BASE_ADDRESS do C
                if daddress(15 downto 0) = MY_WORD_ADDRESS then
                    reg_input_a <= unsigned(ddata_w);
                    start_sig   <= '1';
                
                -- Endereço Base + 1 palavra -> Equivalente a TFT_BASE_ADDRESS + 4 no C
                elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + 1) then
                    reg_input_b <= unsigned(ddata_w);
                    
                -- Endereço Base + 2 palavras -> Equivalente a TFT_BASE_ADDRESS + 8 no C
                elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + 2) then
                    reg_input_c <= unsigned(ddata_w);
                end if;
            end if;
        end if;
    end process;
end architecture;
