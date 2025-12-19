-------------------------------------------------------------------
-- Name        : modbus_rtu.vhd
-- Author      : Guilherme da Costa Franco
-- Description : Simplified Modbus RTU Protocol Implementation
--               for Questa Simulation
-- Version     : 1.0 - Initial simplified version
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity modbus_rtu is
    generic(
        --! Chip select
        MY_CHIPSELECT     : std_logic_vector(1 downto 0) := "10";
        MY_WORD_ADDRESS   : unsigned(15 downto 0)        := x"0040";
        DADDRESS_BUS_SIZE : integer                      := 32;
        SLAVE_ADDRESS     : std_logic_vector(7 downto 0) := x"01"  -- Endereço do escravo
    );

    port(
        clk        : in  std_logic;
        rst        : in  std_logic;
        
        -- Core data bus signals
        daddress   : in  unsigned(DADDRESS_BUS_SIZE - 1 downto 0);
        ddata_w    : in  std_logic_vector(31 downto 0);
        ddata_r    : out std_logic_vector(31 downto 0);
        d_we       : in  std_logic;
        d_rd       : in  std_logic;
        dcsel      : in  std_logic_vector(1 downto 0);
        dmask      : in  std_logic_vector(3 downto 0);

        -- Debug outputs
        debug_state : out std_logic_vector(3 downto 0);
        debug_crc   : out std_logic_vector(15 downto 0)
    );
end entity modbus_rtu;

architecture RTL of modbus_rtu is

    -- Estados da máquina de estados
    type state_type is (IDLE, RX_ADDR, RX_FUNC, RX_DATA_H, RX_DATA_L, 
                        RX_CRC_L, RX_CRC_H, PROCESS_CMD, 
                        TX_RESPONSE, DONE);
    signal state : state_type := IDLE;

    -- Registradores internos Modbus
    signal rx_address    : std_logic_vector(7 downto 0) := (others => '0');
    signal rx_function   : std_logic_vector(7 downto 0) := (others => '0');
    signal rx_data_high  : std_logic_vector(7 downto 0) := (others => '0');
    signal rx_data_low   : std_logic_vector(7 downto 0) := (others => '0');
    signal rx_crc_low    : std_logic_vector(7 downto 0) := (others => '0');
    signal rx_crc_high   : std_logic_vector(7 downto 0) := (others => '0');
    
    -- Registradores de resposta
    signal tx_data       : std_logic_vector(7 downto 0) := (others => '0');
    signal response_ready: std_logic := '0';
    
    -- CRC calculation
    signal calculated_crc : std_logic_vector(15 downto 0) := x"FFFF";
    signal crc_valid      : std_logic := '0';
    
    -- Registradores de controle e status
    signal control_reg   : std_logic_vector(31 downto 0) := (others => '0');
    signal status_reg    : std_logic_vector(31 downto 0) := (others => '0');
    signal data_reg      : std_logic_vector(31 downto 0) := (others => '0');
    
    -- Holding Registers (simplificado - 4 registradores de 16 bits)
    type holding_registers_type is array (0 to 3) of std_logic_vector(15 downto 0);
    signal holding_registers : holding_registers_type := (
        x"0000", x"0000", x"0000", x"0000"
    );
    
    -- Bits de controle
    constant START_RX_BIT   : integer := 0;  -- Inicia recepção
    constant START_TX_BIT   : integer := 1;  -- Inicia transmissão
    constant ENABLE_BIT     : integer := 2;  -- Habilita Modbus
    
    -- Bits de status
    constant RX_COMPLETE_BIT : integer := 0; -- Recepção completa
    constant TX_COMPLETE_BIT : integer := 1; -- Transmissão completa
    constant CRC_ERROR_BIT   : integer := 2; -- Erro de CRC
    constant ADDR_MATCH_BIT  : integer := 3; -- Endereço corresponde
    
    -- Contador para controle
    signal byte_count : integer range 0 to 255 := 0;
    
    -- Function para CRC16 Modbus
    function crc16_update(crc_in : std_logic_vector(15 downto 0); 
                         data_in : std_logic_vector(7 downto 0)) 
                         return std_logic_vector is
        variable crc : unsigned(15 downto 0);
        variable data : unsigned(7 downto 0);
    begin
        crc := unsigned(crc_in);
        data := unsigned(data_in);
        
        crc := crc xor (resize(data, 16));
        
        for i in 0 to 7 loop
            if (crc(0) = '1') then
                crc := shift_right(crc, 1) xor x"A001";
            else
                crc := shift_right(crc, 1);
            end if;
        end loop;
        
        return std_logic_vector(crc);
    end function;

begin

    -- Debug outputs
    debug_state <= std_logic_vector(to_unsigned(state_type'pos(state), 4));
    debug_crc   <= calculated_crc;

    -- Interface de leitura do barramento
    read_process : process(clk, rst)
    begin
        if rst = '1' then
            ddata_r <= (others => '0');
        elsif rising_edge(clk) then
            -- Sempre atualiza ddata_r quando há leitura válida
            -- Mantém o último valor lido mesmo após d_rd ir para '0'
            if (dcsel = MY_CHIPSELECT) then
                if (d_rd = '1') then
                    -- Registrador de status (offset 0x0000)
                    if daddress(15 downto 0) = (MY_WORD_ADDRESS + x"0000") then
                        ddata_r <= status_reg;
                    
                -- Registrador de dados RX (offset 0x0001)
                elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + x"0001") then
                    ddata_r <= rx_crc_high & rx_crc_low & rx_data_high & rx_data_low;
                    
                -- Função e endereço (offset 0x0002)
                elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + x"0002") then
                    ddata_r <= x"0000" & rx_function & rx_address;
                    
                -- Holding registers (offset 0x0003 a 0x0006)
                elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + x"0003") then
                    ddata_r <= holding_registers(1) & holding_registers(0);
                    report "READ 0x0003: reg0=" & integer'image(to_integer(unsigned(holding_registers(0)))) & 
                           " reg1=" & integer'image(to_integer(unsigned(holding_registers(1))));
                elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + x"0004") then
                    ddata_r <= holding_registers(3) & holding_registers(2);
                    else
                        ddata_r <= (others => '0');  -- Endereço inválido retorna zero
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- Interface de escrita do barramento
    write_process : process(clk, rst)
    begin
        if rst = '1' then
            control_reg <= (others => '0');
            data_reg    <= (others => '0');
            rx_address  <= (others => '0');
            rx_function <= (others => '0');
            rx_data_high <= (others => '0');
            rx_data_low  <= (others => '0');
            -- Reset holding registers
            for i in 0 to 3 loop
                holding_registers(i) <= (others => '0');
            end loop;
        elsif rising_edge(clk) then
            -- Auto-clear start bits
            control_reg(START_RX_BIT) <= '0';
            control_reg(START_TX_BIT) <= '0';
            
            if (d_we = '1') and (dcsel = MY_CHIPSELECT) then
                -- Registrador de controle (offset 0x0000)
                if daddress(15 downto 0) = (MY_WORD_ADDRESS + x"0000") then
                    control_reg <= ddata_w;
                    
                -- Registrador de dados para TX (offset 0x0001)
                elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + x"0001") then
                    data_reg <= ddata_w;
                    
                -- Simular recepção de bytes (para teste)
                elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + x"0010") then
                    rx_address <= ddata_w(7 downto 0);
                elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + x"0011") then
                    rx_function <= ddata_w(7 downto 0);
                elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + x"0012") then
                    rx_data_high <= ddata_w(7 downto 0);
                elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + x"0013") then
                    rx_data_low <= ddata_w(7 downto 0);
                    
                -- Escrita nos Holding Registers
                elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + x"0003") then
                    holding_registers(0) <= ddata_w(15 downto 0);
                    holding_registers(1) <= ddata_w(31 downto 16);
                    report "WRITE 0x0003: data=" & integer'image(to_integer(unsigned(ddata_w)));
                elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + x"0004") then
                    holding_registers(2) <= ddata_w(15 downto 0);
                    holding_registers(3) <= ddata_w(31 downto 16);
                end if;
            end if;
        end if;
    end process;

    -- Máquina de estados principal do Modbus
    modbus_fsm : process(clk, rst)
        variable crc_temp : std_logic_vector(15 downto 0);
    begin
        if rst = '1' then
            state <= IDLE;
            status_reg <= (others => '0');
            calculated_crc <= x"FFFF";
            crc_valid <= '0';
            byte_count <= 0;
            
        elsif rising_edge(clk) then
            
            case state is
                when IDLE =>
                    status_reg(RX_COMPLETE_BIT) <= '0';
                    status_reg(TX_COMPLETE_BIT) <= '0';
                    calculated_crc <= x"FFFF";
                    byte_count <= 0;
                    
                    if control_reg(ENABLE_BIT) = '1' and control_reg(START_RX_BIT) = '1' then
                        state <= RX_ADDR;
                    end if;
                    
                when RX_ADDR =>
                    -- Calcula CRC do endereço
                    calculated_crc <= crc16_update(calculated_crc, rx_address);
                    
                    -- Verifica se o endereço corresponde
                    if rx_address = SLAVE_ADDRESS or rx_address = x"00" then
                        status_reg(ADDR_MATCH_BIT) <= '1';
                        state <= RX_FUNC;
                    else
                        status_reg(ADDR_MATCH_BIT) <= '0';
                        state <= IDLE;
                    end if;
                    
                when RX_FUNC =>
                    -- Calcula CRC da função
                    calculated_crc <= crc16_update(calculated_crc, rx_function);
                    state <= RX_DATA_H;
                    
                when RX_DATA_H =>
                    -- Calcula CRC do byte alto de dados
                    calculated_crc <= crc16_update(calculated_crc, rx_data_high);
                    state <= RX_DATA_L;
                    
                when RX_DATA_L =>
                    -- Calcula CRC do byte baixo de dados
                    calculated_crc <= crc16_update(calculated_crc, rx_data_low);
                    state <= RX_CRC_L;
                    
                when RX_CRC_L =>
                    -- Recebe byte baixo do CRC
                    state <= RX_CRC_H;
                    
                when RX_CRC_H =>
                    -- Verifica CRC
                    if calculated_crc = (rx_crc_high & rx_crc_low) then
                        crc_valid <= '1';
                        status_reg(CRC_ERROR_BIT) <= '0';
                        state <= PROCESS_CMD;
                    else
                        crc_valid <= '0';
                        status_reg(CRC_ERROR_BIT) <= '1';
                        state <= DONE;
                    end if;
                    
                when PROCESS_CMD =>
                    -- Processa comando Modbus
                    case rx_function is
                        -- Function 03: Read Holding Registers
                        when x"03" =>
                            tx_data <= holding_registers(to_integer(unsigned(rx_data_low(1 downto 0))))(7 downto 0);
                            state <= TX_RESPONSE;
                            
                        -- Function 06: Write Single Register
                        -- A escrita sera feita via barramento, nao diretamente aqui
                        when x"06" =>
                            state <= TX_RESPONSE;
                            
                        when others =>
                            -- Função não suportada
                            status_reg(CRC_ERROR_BIT) <= '1';
                            state <= DONE;
                    end case;
                    
                when TX_RESPONSE =>
                    response_ready <= '1';
                    state <= DONE;
                    
                when DONE =>
                    status_reg(RX_COMPLETE_BIT) <= '1';
                    status_reg(TX_COMPLETE_BIT) <= response_ready;
                    response_ready <= '0';
                    
                    if control_reg(START_RX_BIT) = '0' then
                        state <= IDLE;
                    end if;
                    
            end case;
        end if;
    end process;

end architecture RTL;
