library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.decoder_types.all;

entity coretestbench is
	generic(
		--! Num of 32-bits memory words
		IMEMORY_WORDS : integer := 1024;	--!= 4K (1024 * 4) bytes
		DMEMORY_WORDS : integer := 1024;  	--!= 2k (512 * 2) bytes
		constant SIZE : integer := 8		-- 8 bytes UART package
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


end entity coretestbench;

architecture RTL of coretestbench is

	signal clk       : std_logic;
	signal clk_sdram : std_logic;
	signal clk_vga   : std_logic;
	signal rst       : std_logic;
	signal rst_n     : std_logic;

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
	signal ddata_r_periph : std_logic_vector(31 downto 0) := (others => '0');
	signal ddata_r_gpio : std_logic_vector(31 downto 0);
	signal ddata_r_uart : std_logic_vector(31 downto 0):=(others => '0');

	signal d_rd : std_logic;

	signal input_in	: std_logic_vector(31 downto 0);
	signal cpu_state    : cpu_state_t;

	signal debugString  : string(1 to 40) := (others => '0');

	signal d_sig : std_logic;

	-- UART Signals
	signal clk_baud : std_logic;
	signal data_in : std_logic_vector(7 downto 0);
	signal tx : std_logic;
	signal start : std_logic;
	signal tx_cmp : std_logic;
	signal data_out : std_logic_vector(SIZE-1 downto 0);
	signal rx : std_logic;
	signal rx_cmp : std_logic;
	signal config_all : std_logic_vector (31 downto 0);
	signal transmit_byte: std_logic_vector(7 downto 0) := x"23";
  signal transmit_frame: std_logic_vector(9 downto 0) := (others => '1');
	signal clk_state: boolean := FALSE;
	signal cnt_rx : integer := 0;


	signal csel_uart : std_logic;

	-- I/O signals
	signal gpio_input : std_logic_vector(31 downto 0);
	signal gpio_output : std_logic_vector(31 downto 0);
	signal display_seg: std_logic_vector(7 downto 0);
	signal display_data: std_logic_vector(3 downto 0);

	signal dmemory_address : natural;

	signal uart_interrup: std_logic;
	signal interrupts_combo : std_logic_vector(31 downto 0);
	signal gpio_interrupts : std_logic_vector(6 downto 0);


begin

	clock_driver : process
		constant period : time := 1000 ns;
	begin
		clk <= '0';
		--wait for period / 2;
		wait for 1 ns;
		clk <= '1';
		wait for 1 ns;
		--wait for period / 2;
	end process clock_driver;

	reset : process is
	begin
		rst <= '1';
		wait for 5 ns;
		rst <= '0';
		wait;
	end process reset;

	clock_baud : process
		constant period : time := 26041 ns;
	begin
		clk_baud <= '0';
		clk_state <= FALSE;
		wait for 2 ns;
		--wait for period / 2;
		clk_baud <= '1';
		clk_state <= TRUE;
		wait for 2 ns;
		--wait for period / 2;
	end process clock_baud;

	rst_n <= not rst;

	process(d_rd, dcsel, daddress, iaddress)
	begin
		if (d_rd = '1') and (dcsel = "00") then
			address <= std_logic_vector(to_unsigned(daddress, 32));
		else
			address <= std_logic_vector(to_unsigned(iaddress, 32));
		end if;
	end process;

	-- 32-bits x 1024 words quartus RAM (dual port: portA -> riscV, portB -> In-System Mem Editor
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
			rst     => rst,
			clk     => clk,
			data    => ddata_w,
			address => dmemory_address,
			we      => d_we,
			csel    => dcsel(0),
			signal_ext => d_sig,
			dmask   => dmask,
			q       => ddata_r_mem
		);

	-- Adress space mux ((check sections.ld) -> Data chip select:
	-- 0x00000    ->    Instruction memory
	-- 0x20000    ->    Data memory
	-- 0x40000    ->    Input/Output generic address space
	-- 0x60000    ->    SDRAM address space
	with dcsel select ddata_r <=
		idata when "00",
		ddata_r_mem when "01",
		ddata_r_periph	 when "10",
		(others => '0') when others;

		with to_unsigned(daddress,16)(15 downto 4) select
	        ddata_r_periph <= ddata_r_gpio when x"000",
														ddata_r_uart when x"002",
	                          (others => '0')when others;

	-- Softcore instatiation
	myRiscv : entity work.core
	generic map(
		IMEMORY_WORDS => IMEMORY_WORDS,
		DMEMORY_WORDS => DMEMORY_WORDS
	)
	port map(
		clk      => clk,
		rst      => rst,
		iaddress => iaddress,
		idata    => idata,
		daddress => daddress,
		ddata_r  => ddata_r,
		ddata_w  => ddata_w,
		d_we     => d_we,
		d_rd     => d_rd,
		dcsel    => dcsel,
		dmask    => dmask,
		interrupts=>interrupts_combo,
		state    => cpu_state
	);

	interrupts_combo(24 downto 18)<=gpio_interrupts(6 downto 0);
	interrupts_combo(31) <= uart_interrup;

	-- FileOutput DEBUG
	debug : entity work.trace_debug
	generic map(
		MEMORY_WORDS => 1024
	)
	port map(
		pc   => iaddress,
		data => idata,
		inst => debugString
	);

	generic_gpio: entity work.gpio
		generic map(
			MY_CHIPSELECT   => "10",
			MY_WORD_ADDRESS => x"10"
		)
		port map(
			clk      => clk,
			rst      => rst,
			daddress => daddress,
			ddata_w  => ddata_w,
			ddata_r  => ddata_r_gpio,
			d_we     => d_we,
			d_rd     => d_rd,
			dcsel    => dcsel,
			dmask    => dmask,
			input    => gpio_input,
			output   => gpio_output,
			gpio_interrupts => gpio_interrupts
		);

	uart_plus : entity work.uart
	port map(
		clk_in_1M  => clk,
		clk_baud   => clk_baud,
		csel       => csel_uart,
		data_in    => data_in,
		tx         => tx,
		tx_cmp     => tx_cmp,
		data_out   => data_out,
		rx         => rx,
		rx_cmp     => rx_cmp,
		config_all => config_all,
		interrupt => uart_interrup
	);

	seven_seg: entity work.display_dec
		port map(
			data_in => ddata_w(3 downto 0),
			disp => display_seg
		);


	-- Connect gpio data to output hardware
	LEDR(7 downto 0) <= gpio_output(7 downto 0);

	-- Output register
	process(clk, rst)
	        constant SEGMETS_BASE_ADDRESS : unsigned(15 downto 0):=x"0010";
    begin
        if rst = '1' then
                -- Turn off all HEX displays
            HEX0 <= (others => '1');
            HEX1 <= (others => '1');
            HEX2 <= (others => '1');
            HEX3 <= (others => '1');
            HEX4 <= (others => '1');
				HEX5 <= (others => '1');
        else
            if rising_edge(clk) then
                if (d_we = '1') and (dcsel = "10") then
                    -- ToDo: Simplify compartors
                    -- ToDo: Maybe use byte addressing?
                    --       x"01" (word addressing) is x"04" (byte addressing)

                    if to_unsigned(daddress, 32)(15 downto 0) =(SEGMETS_BASE_ADDRESS + x"0000") then -- TIMER_ADDRESS
                        HEX0 <= display_seg;
                    elsif to_unsigned(daddress, 32)(15 downto 0) =(SEGMETS_BASE_ADDRESS + x"0001") then -- TIMER_ADDRESS
                        HEX1 <= display_seg;
                    elsif to_unsigned(daddress, 32)(15 downto 0) =(SEGMETS_BASE_ADDRESS + x"0002") then -- TIMER_ADDRESS
                        HEX2 <= display_seg;
                    elsif to_unsigned(daddress, 32)(15 downto 0) =(SEGMETS_BASE_ADDRESS + x"0003") then -- TIMER_ADDRESS
                        HEX3 <= display_seg;
                    elsif to_unsigned(daddress, 32)(15 downto 0) =(SEGMETS_BASE_ADDRESS + x"0004") then -- TIMER_ADDRESS
                        HEX4 <= display_seg;
                    elsif to_unsigned(daddress, 32)(15 downto 0) =(SEGMETS_BASE_ADDRESS + x"0005") then -- TIMER_ADDRESS
                        HEX5 <= display_seg;
                    end if;
                end if;
            end if;
        end if;
    end process;

	-- Output register
		process(clk, rst)
	   constant UART_BASE_ADDRESS : unsigned(15 downto 0):=x"0020";
  	 begin
			if rst = '1' then
				data_in <= (others => '0');
				config_all <= (others => '0');
      elsif rising_edge(clk) then

				csel_uart <= '0';

        if (d_we = '1') and (dcsel = "10") then
            if to_unsigned(daddress, 32)(15 downto 0) =(UART_BASE_ADDRESS + x"0000") then -- TIMER_ADDRESS
                data_in <= ddata_w(7 downto 0);
								csel_uart <= '1';
            elsif to_unsigned(daddress, 32)(15 downto 0) =(UART_BASE_ADDRESS + x"0002") then -- TIMER_ADDRESS
                config_all <= ddata_w(31 downto 0);
            end if;
        end if;

      end if;
	end process;

	-- Input register
		process(clk, rst)
	   constant UART_BASE_ADDRESS : unsigned(15 downto 0):=x"0020";
  	 begin
			if rst = '1' then
			 	ddata_r_uart <= (others => '0');
			else
	      if rising_edge(clk) then
	        if (d_rd = '1') and (dcsel = "10") then
	            if to_unsigned(daddress, 32)(15 downto 0) = (UART_BASE_ADDRESS + x"0001") then -- TIMER_ADDRESS
	                ddata_r_uart(7 downto 0) <= data_out;
	            end if;
	        end if;
	      end if;
			end if;
	end process;

	data_transmit_proc: process
  begin
    wait for 2 us;
    wait until clk_state;
    rx <= '0';
    for i in 0 to 8 loop
			rx <= (transmit_frame(cnt_rx));
			cnt_rx <= cnt_rx + 1;
			wait until clk_state;
		end loop;
    cnt_rx <= 0;
    rx <= '1';
    wait for 2 us;
  end process;

	transmit_byte <= x"89" after 1 us, x"A5" after 4 us;
  transmit_frame <= '1' & transmit_byte & '0';



end architecture RTL;
