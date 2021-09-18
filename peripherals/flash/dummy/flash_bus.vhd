library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity flash_bus is
  generic (
    -- chip select
    MY_CHIPSELECT   : std_logic_vector(1 downto 0) := "00";
    DADDRESS_BUS_SIZE : integer := 32;
    -- if 'daddress' is a shared bus, we may need to setup a daddress offset
    DADDRESS_OFFSET : integer := 0
  );
  port (
    clk   : in STD_LOGIC; -- system clock
    rst   : in STD_LOGIC; -- asynchronous reset

    -- core data bus signals
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

    -- dummy memory. 32-bit based addresses.
    type reg_array is array (0 to SECTOR_5_ADDR_END) of std_logic_vector (DADDRESS_BUS_SIZE-1 downto 0);
    
    impure function InitFlash return reg_array is		
      variable FLASH : reg_array;	
    begin
      for i in reg_array'range loop
        FLASH(i) := (others => '1');		
      end loop;
        return FLASH;	
      end function;	
      
    signal memory : reg_array := initFlash;

  begin
   
  -- state transition (moore)
  process (clk, rst, dcsel)
  begin
    if rst = '1' OR dcsel /= MY_CHIPSELECT then
      state <= IDLE;
    elsif rising_edge(clk) then
      
      case state is
        when IDLE =>

          -- address within boundaries?
          if daddress >= 0 and daddress <= SECTOR_5_ADDR_END then
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

        ddata_r <= memory(to_integer(daddress));

      when READING =>

      when RDONE =>

      when WREQUEST =>

        memory(to_integer(daddress)) <= ddata_w;
      
      when WRITING =>
      when WDONE =>

    end case;
  end process;
   
end rtl;