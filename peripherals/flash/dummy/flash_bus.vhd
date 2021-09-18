library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity flash_bus is
  generic (
    -- chip select: currently databus mux has only 2-bit size (see the file
    -- databusmux.vhd). We will use chipselect "11" (the same of SRAM). To
    -- differentiate between SRAM and FLASH, we will use a offset for flash.

    -- Address (byte based) space and chip select:
    -- 0x0000000000 ->  0b000 0000 0000 0000 0000 0000 0000 -> Instruction memory
    -- 0x0002000000 ->  0b010 0000 0000 0000 0000 0000 0000 -> Data memory
    -- 0x0004000000 ->  0b100 0000 0000 0000 0000 0000 0000 -> Input/Output generic address space
    -- 0x0006000000 ->  0b110 0000 0000 0000 0000 0000 0000 -> SDRAM
    -- 0x0007000000 ->  0b111 0000 0000 0000 0000 0000 0000 -> FLASH

    MY_CHIPSELECT   : std_logic_vector(1 downto 0) := "11";
    DADDRESS_BUS_SIZE : integer := 32;
    -- offset from SDRAM base address - this is a word (32-bit) based offset.
    DADDRESS_OFFSET : integer := 16#400000#
  );
  port (
    clk   : in STD_LOGIC; -- system clock
    rst   : in STD_LOGIC; -- asynchronous reset

    -- core data bus signals

    -- daddress is a word based address
    daddress  : in   unsigned(DADDRESS_BUS_SIZE-1 downto 0); --! Data address
    ddata_w   : in	 std_logic_vector(31 downto 0);          --! Data to memory bus
    ddata_r	  : out  std_logic_vector(31 downto 0);          --! Data from memory bus
    d_we      : in   std_logic;                              --! Write Enable
    d_rd	    : in   std_logic;                              --! Read enable
    dcsel	    : in   std_logic_vector(1 downto 0);	         --! Chip select
    dmask     : in   std_logic_vector(3 downto 0) 	         --! Byte enable mask
  );
end flash_bus;

architecture rtl of flash_bus is
	 
    -- the end addresses of flash sectors. 32-bit based.
	  constant SECTOR_1_ADDR_END	: natural := 16#01FFF#;
	  constant SECTOR_2_ADDR_END	: natural := 16#03FFF#;
	  constant SECTOR_3_ADDR_END	: natural := 16#1BFFF#;
	  constant SECTOR_4_ADDR_END	: natural := 16#2DFFF#;
	  constant SECTOR_5_ADDR_END	: natural := 16#57FFF#;

    -- R: READ, W: WRITE, E: ERASE
    type FSM is (IDLE, RREQUEST, READING, RDONE, WREQUEST, WRITING, WDONE);
    signal state : FSM;

    -- dummy memory. word (32-bit) based addresses.
    type reg_array is array (0 to SECTOR_5_ADDR_END) of std_logic_vector (DADDRESS_BUS_SIZE-1 downto 0);
    
    -- function to initialize dummy flash content
    impure function InitFlash return reg_array is		
      variable FLASH : reg_array;	
    begin
      for i in reg_array'range loop
        FLASH(i) := (others => '1');		
      end loop;
        return FLASH;	
      end function;	
      
    signal memory : reg_array := initFlash;

    -- addr_local will contain the flash word (32-bit) based address without
    -- offset. i.e. this is the correct address use internally in this component
    signal addr_local : unsigned(22 downto 0);

  begin
  
  -- state transition (moore)
  process (clk, rst, dcsel)
  begin
    if rst = '1' OR dcsel /= MY_CHIPSELECT then
      state <= IDLE;
    elsif rising_edge(clk) then
      
      case state is
        when IDLE =>

          -- address within boundaries? note that we do not consider bits 23,
          -- 24... of daddress because they contain mux information
          if daddress(22 downto 0) >= DADDRESS_OFFSET and daddress(22 downto 0) <= (DADDRESS_OFFSET + SECTOR_5_ADDR_END) then

            -- addr_local contains the flash 32-bit based address without offset.
            addr_local <= daddress(22 downto 0) - to_unsigned(DADDRESS_OFFSET, 23);

            -- read mode
            if d_rd = '1' and d_we = '0' then 
              state <= RREQUEST;
            -- write mode
            elsif d_we = '1' and d_rd = '0' then
              state <= WREQUEST;
            -- erase mode
            elsif d_we = '1' and d_rd = '1' then
              -- state <= EREQUEST;
            end if;
          end if;

        when RREQUEST =>
        
          state <= READING;

        when READING =>

          state <= RDONE;

        when RDONE =>

          state <= IDLE;

        when WREQUEST =>

          state <= WRITING;
  
        when WRITING =>

          state <= WDONE;

        when WDONE =>

          state <= IDLE;

      end case;

    end if;
  end process;

  -- mealy
  process (state)
  begin

    case state is
      when IDLE =>

      when RREQUEST =>

        ddata_r <= memory(to_integer(addr_local));

      when READING =>

      when RDONE =>

      when WREQUEST =>

        memory(to_integer(addr_local)) <= ddata_w;
      
      when WRITING =>
      when WDONE =>

    end case;
  end process;
   
end rtl;