library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.decoder_types.all;

entity tb_adc is
    generic(
        IMEMORY_WORDS : integer := 1024;
        DMEMORY_WORDS : integer := 1024
    );

    port(
        ----------- SEG7 ------------
        HEX0 : out std_logic_vector(7 downto 0);
        HEX1 : out std_logic_vector(7 downto 0);
        HEX2 : out std_logic_vector(7 downto 0);
        HEX3 : out std_logic_vector(7 downto 0);
        HEX4 : out std_logic_vector(7 downto 0);
        HEX5 : out std_logic_vector(7 downto 0);
        ----------- SW ------------

        SW: in std_logic_vector(9 downto 0);
        LEDR: out std_logic_vector(9 downto 0);
        
        ---------- ARDUINO IO -----
        ARDUINO_IO: inout std_logic_vector(15 downto 0)
    );
end entity tb_adc;

architecture rtl of tb_adc is
    signal clk       : std_logic;
    signal clk_adc   : std_logic;
    signal rst       : std_logic;
    signal idata : std_logic_vector(31 downto 0);

    signal daddress : natural;
    signal ddata_r  : std_logic_vector(31 downto 0);
    signal ddata_w  : std_logic_vector(31 downto 0);
    signal dmask    : std_logic_vector(3 downto 0);
    signal dcsel    : std_logic_vector(1 downto 0);
    signal d_we     : std_logic := '0';

    signal iaddress : integer range 0 to IMEMORY_WORDS - 1 := 0;

    signal address     : std_logic_vector(31 downto 0);

    signal ddata_r_mem : std_logic_vector(31 downto 0);
    signal d_rd : std_logic;

    signal input_in	: std_logic_vector(31 downto 0);
    signal cpu_state    : cpu_state_t;

    signal debugString  : string(1 to 40) := (others => '0');

    signal dmemory_address : natural;
    signal d_sig : std_logic;

    signal interrupts : std_logic_vector(31 downto 0);
    signal mySignal_d : std_logic_vector(31 downto 0);
    signal mySignal_re : std_logic_vector(31 downto 0);
    -- I/O signals
    signal ddata_r_gpio : std_logic_vector(31 downto 0);
    signal adc_input : std_logic_vector(31 downto 0);
    signal adc_output: std_logic_vector(31 downto 0);
    signal disp7_output : std_logic_vector(7 downto 0);
    
    -- GPIO
    signal gpio_input       : std_logic_vector(31 downto 0);
    signal gpio_output      : std_logic_vector(31 downto 0);
    signal gpio_interrupts  : std_logic_vector(6 downto 0);  
    
begin

    clock_driver: process
        constant period : time := 1000 ns;
    begin
        clk <= '0';
        wait for period/2;
        clk <= '1';
        wait for period/2;
    end process clock_driver;

    clock_adc: process
        constant adc_period : time := 100000 ns;
    begin
        clk_adc <= '0';
        wait for adc_period/2; 
        clk_adc <= '1';
        wait for adc_period/2; 
    end process clock_adc;

    interrupt_edge : process (clk, rst) is
    begin
        if rst = '1' then
    
        elsif rising_edge(clk) then
    
            mySignal_d <= interrupts;
            mySignal_re <= not mySignal_d and interrupts;
    
        end if;
    end process interrupt_edge;

    interrupt_generate : process is
    begin
        interrupts <=x"0000_0000";
        wait for 186 us;
        interrupts <=x"0004_0000";
        wait for 1 us;
        interrupts <=x"0000_0000";
        wait for 200 us;
        interrupts <=x"0004_0000";
        wait for 1 us;
        interrupts <=x"0000_0000";
        wait for 40 us;
        interrupts <=x"0400_0000";
        wait for 1 us;
        interrupts <=x"0000_0000";
        wait for 327 us;
        interrupts <=x"0004_0000";
        wait for 1 us;
        interrupts <=x"0000_0000";
        wait for 12 us;
        interrupts <=x"0004_0000";
        wait for 1 us;
        interrupts <=x"0000_0000";
    
        wait;
    end process interrupt_generate;

    reset: process is
    begin
        rst <= '1';
        wait for 5 ns;
        rst <= '0';
        wait;
    end process reset;
    
    -- IMem shoud be read from instruction and data buses
    -- Not enough RAM ports for instruction bus, data bus and in-circuit programming
    -- with dcsel select 
    -- address <= std_logic_vector(to_unsigned(daddress,10)) when "01",
    --			   std_logic_vector(to_unsigned(iaddress,10)) when others;				   
    process(d_rd, dcsel, daddress, iaddress)
    begin
        if (d_rd = '1') and (dcsel = "00") then
            address <= std_logic_vector(to_unsigned(daddress, 32));
        else
            address <= std_logic_vector(to_unsigned(iaddress, 32));
        end if;
    end process;

    iram_quartus_inst : entity work.iram_quartus
        port map(
            address => address(9 downto 0),
            byteena => "1111",
            clock   => clk,
            data    => (others => '0'),
            wren    => '0',
            q       => idata
        );

    dmemory_address <= to_integer(to_unsigned(daddress, 10));
 -- Data Memory RAM
    dmem : entity work.dmemory
        generic map(
            MEMORY_WORDS => DMEMORY_WORDS
        )
        port map(
            rst         => rst,
            clk         => clk,
            data        => ddata_w,
            address     => dmemory_address,
            we          => d_we,
            signal_ext  => d_sig,
            csel        => dcsel(0),
            dmask       => dmask,
            q           => ddata_r_mem
        );

    -- Adress space mux ((check sections.ld) -> Data chip select:
    -- 0x00000    ->    Instruction memory
    -- 0x20000    ->    Data memory
    -- 0x40000    ->    Input/Output generic address space
    -- 0x60000    ->    SDRAM address space	
    with dcsel select ddata_r <=
        idata when "00",
        ddata_r_mem when "01",
        input_in when "10",
        (others => '0') when others;
    
    -- Softcore instatiation
    myRiscv : entity work.core
        generic map(
            IMEMORY_WORDS => IMEMORY_WORDS,
            DMEMORY_WORDS => DMEMORY_WORDS
        )
    port map(
        clk        => clk,
        rst        => rst,
        iaddress   => iaddress,
        idata      => idata,
        daddress   => daddress,
        ddata_r    => ddata_r,
        ddata_w    => ddata_w,
        d_we       => d_we,
        d_rd       => d_rd,
        d_sig      => d_sig,
        dcsel      => dcsel,
        dmask      => dmask,
        interrupts => interrupts,
        state      => cpu_state
    );
    
	generic_gpio: entity work.gpio
	generic map(
		MY_CHIPSELECT   => "10",
		MY_WORD_ADDRESS => x"10"
	)
	port map(
		clk             => clk,
		rst             => rst,
		daddress        => daddress,
		ddata_w         => ddata_w,
		ddata_r         => ddata_r_gpio,
		d_we            => d_we,
		d_rd            => d_rd,
		dcsel           => dcsel,
		dmask           => dmask,
		input           => gpio_input,
		output          => gpio_output,
		gpio_interrupts => gpio_interrupts
	);
	
    adc_bus: entity work.adc_bus
        generic map(
            MY_CHIPSELECT   => "10",
            MY_WORD_ADDRESS => x"10"
        )
        port map(
            clk      => clk,
            rst      => rst,
            clk_adc  => clk_adc,
            daddress => daddress,
            ddata_w  => ddata_w,
            ddata_r  => input_in,
            d_we     => d_we,
            d_rd     => d_rd,
            dcsel    => dcsel,
            dmask    => dmask
        );

    HEX0 <= (others => '1');
    HEX1 <= (others => '1');
    HEX2 <= (others => '1');
    HEX3 <= (others => '1');
    HEX4 <= (others => '1');
    HEX5 <= (others => '1');

    -- FileOutput DEBUG 
    debug : entity work.trace_debug
        generic map(
            MEMORY_WORDS => IMEMORY_WORDS
        )
        port map(
            pc   => iaddress,
            data => idata,
            inst => debugString
        );

end architecture rtl;