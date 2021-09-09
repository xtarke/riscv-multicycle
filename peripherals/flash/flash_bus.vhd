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
    daddress  : in  unsigned(DADDRESS_BUS_SIZE-1 downto 0);  --! Data address
    ddata_w   : in	 std_logic_vector(31 downto 0);             --! Data to memory bus
    ddata_r	  : out  std_logic_vector(31 downto 0);             --! Data from memory bus
    d_we      : in   std_logic;                                 --! Write Enable
    d_rd	  : in   std_logic;                                 --! Read enable
    dcsel	  : in   std_logic_vector(1 downto 0);	            --! Chip select
    dmask     : in   std_logic_vector(3 downto 0)	            --! Byte enable mask
  );
end flash_bus;

architecture rtl of flash_bus is
	 
    component flash is
      port (
        clock                   : in  std_logic                     := 'X';             -- clk
        avmm_csr_addr           : in  std_logic                     := 'X';             -- address
        avmm_csr_read           : in  std_logic                     := 'X';             -- read
        avmm_csr_writedata      : in  std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
        avmm_csr_write          : in  std_logic                     := 'X';             -- write
        avmm_csr_readdata       : out std_logic_vector(31 downto 0);                    -- readdata
        avmm_data_addr          : in  std_logic_vector(18 downto 0) := (others => 'X'); -- address
        avmm_data_read          : in  std_logic                     := 'X';             -- read
        avmm_data_writedata     : in  std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
        avmm_data_write         : in  std_logic                     := 'X';             -- write
        avmm_data_readdata      : out std_logic_vector(31 downto 0);                    -- readdata
        avmm_data_waitrequest   : out std_logic;                                        -- waitrequest
        avmm_data_readdatavalid : out std_logic;                                        -- readdatavalid
        avmm_data_burstcount    : in  std_logic_vector(1 downto 0)  := (others => 'X'); -- burstcount
        reset_n                 : in  std_logic                     := 'X'              -- reset_n
      );
    end component flash;

    -- the end addresses of flash sectors. 32-bit based.
	  constant SECTOR_1_ADDR_END	: natural := 16#01FFF#;
	  constant SECTOR_2_ADDR_END	: natural := 16#03FFF#;
	  constant SECTOR_3_ADDR_END	: natural := 16#1BFFF#;
	  constant SECTOR_4_ADDR_END	: natural := 16#2DFFF#;
	  constant SECTOR_5_ADDR_END	: natural := 16#57FFF#;

    signal avmm_data_addr          : std_logic_vector(18 downto 0) := (others => 'X'); -- address
    signal avmm_data_read          : std_logic                     := 'X';             -- read
    signal avmm_data_writedata     : std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
    signal avmm_data_write         : std_logic                     := 'X';             -- write
    signal avmm_data_readdata      : std_logic_vector(31 downto 0);                    -- readdata
    signal avmm_data_waitrequest   : std_logic;                                        -- waitrequest
    signal avmm_data_readdatavalid : std_logic;                                        -- readdatavalid
    signal avmm_data_burstcount    : std_logic_vector(1 downto 0)  := (others => 'X'); -- burstcount
    signal avmm_csr_addr           : std_logic                     := 'X';             -- address
    signal avmm_csr_read           : std_logic                     := 'X';             -- read
    signal avmm_csr_writedata      : std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
    signal avmm_csr_write          : std_logic                     := 'X';             -- write
    signal avmm_csr_readdata       : std_logic_vector(31 downto 0);                     -- readdata

    -- type write_FSM is (START, PROCESSING, FINISHED);
    -- signal write_state : write_FSM;

    -- R: READ, W: WRITE, E: ERASE

    type FSM is (IDLE, RREQUEST, READING, RDONE, WREQUEST, WRITING, WDONE);
    signal state : FSM;

    -- variable offset : std_logic_vector

  begin
   
    avmm_data_addr <= std_logic_vector(daddress(18 downto 0));
    avmm_data_burstcount <= "01";
    ddata_r <= avmm_data_readdata;

    internalFlash : component flash
        port map (
            clock                   => clk,                   --    clk.clk
            reset_n                 => rst,                 -- nreset.reset_n
            
            avmm_data_addr          => avmm_data_addr,          --   data.address
            avmm_data_read          => avmm_data_read,          --       .read
            avmm_data_writedata     => ddata_w,                              --       .writedata
            avmm_data_write         => avmm_data_write,         --       .write
            avmm_data_readdata      => avmm_data_readdata,      --       .readdata
            avmm_data_waitrequest   => avmm_data_waitrequest,   --       .waitrequest
            avmm_data_readdatavalid => avmm_data_readdatavalid, --       .readdatavalid
            avmm_data_burstcount    => avmm_data_burstcount,                               --       .burstcount, 1 = parallel

            avmm_csr_addr           => avmm_csr_addr,           --    csr.address. '0': status regiter, '1': control register.
            avmm_csr_read           => avmm_csr_read,           --       .read
            avmm_csr_writedata      => avmm_csr_writedata,      --       .writedata
            avmm_csr_write          => avmm_csr_write,          --       .write
            avmm_csr_readdata       => avmm_csr_readdata        --       .readdata
        );

  -- state transition (moore)
  process (clk, rst, dcsel)
  begin
    if rst = '1' OR dcsel /= MY_CHIPSELECT then
      state <= IDLE;
    elsif rising_edge(clk) then
      
      case state is
        when IDLE =>

          -- address within boundaries?
          if unsigned(avmm_data_addr) >= 0 and unsigned(avmm_data_addr) <= SECTOR_5_ADDR_END then
            -- read mode
            if d_rd = '1' and d_we = '0' then 
              state <= RREQUEST;
            -- write mode
            elsif d_we = '1' and d_rd = '0' then
              state <= WREQUEST;
            end if;
          end if;

        when RREQUEST =>
        
          state <= READING;

        when READING =>

          if avmm_data_readdatavalid = '1' then
            state <= RDONE;
          end if;

        when RDONE =>
          -- readdatavalid is set to '1' in a successful reading just during a
          -- period of time
          if avmm_data_readdatavalid = '0' then
            state <= IDLE;
          end if;

        when WREQUEST =>

          if avmm_data_waitrequest = '1' then
            state <= WRITING;
          end if;

        when WRITING =>

          if avmm_data_waitrequest = '0' then
            state <= WDONE;
          end if;

        when WDONE =>

          state <= IDLE;

      end case;

    end if;
  end process;

  -- mealy
  process (state, avmm_data_addr)
  begin

    -- ddata_r <= (others => '0');
    -- avmm_data_addr <= (others => '0');
    avmm_data_read <= '0';
    -- avmm_data_writedata <= (others => '0');
    avmm_data_write <= '0';
    -- avmm_data_burstcount <= x"1";
    avmm_csr_addr <= '1'; -- control register
    avmm_csr_read <= '0';
    avmm_csr_writedata <= (others => '1');
    avmm_csr_write <= '0';
    
    case state is
      when IDLE =>

      when RREQUEST =>

        avmm_data_read <= '1';

      when READING =>

        -- avmm_data_read <= '0';

      when RDONE =>

      when WREQUEST =>

        avmm_data_write <= '1';
        -- avmm_csr_addr <= '1'; -- control register
        -- avmm_csr_read <= '0';
        avmm_csr_write <= '1';
        
        -- set write protection to '0' regarding the sector we want to write
        if unsigned(avmm_data_addr) <= SECTOR_1_ADDR_END then
          avmm_csr_writedata(23) <= '0';
        elsif unsigned(avmm_data_addr) <= SECTOR_2_ADDR_END then
          avmm_csr_writedata(24) <= '0';
        elsif unsigned(avmm_data_addr) <= SECTOR_3_ADDR_END then
          avmm_csr_writedata(25) <= '0';
        elsif unsigned(avmm_data_addr) <= SECTOR_4_ADDR_END then
          avmm_csr_writedata(26) <= '0';
        elsif unsigned(avmm_data_addr) <= SECTOR_5_ADDR_END then
          avmm_csr_writedata(27) <= '0';
        end if;
      
      when WRITING =>
      when WDONE =>

    end case;
  end process;
   
end rtl;