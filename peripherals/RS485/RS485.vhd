library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RS485 is
    generic(
        --! Chip selec
        MY_CHIPSELECT   : std_logic_vector(1 downto 0) := "10";
        MY_WORD_ADDRESS : unsigned(15 downto 0)        := x"0170"
    );

    port(
        clk          : in  std_logic;
        rst          : in  std_logic;
        clk_baud     : in  std_logic;
        -- Core data bus signals
        daddress     : in  unsigned(31 downto 0);
        ddata_w      : in  std_logic_vector(31 downto 0);
        ddata_r      : out std_logic_vector(31 downto 0);
        d_we         : in  std_logic;
        d_rd         : in  std_logic;
        dcsel        : in  std_logic_vector(1 downto 0); --! Chip select 
        -- ToDo: Module should mask bytes (Word, half word and byte access)
        dmask        : in  std_logic_vector(3 downto 0); --! Byte enable mask -- @suppress 

        -- hardware input/output signals
        tx_out       : out std_logic;
        rx_out       : in  std_logic;
        interrupts   : out std_logic_vector(1 downto 0); -- @suppress 
        -- sinal de controle de direção [RS485]
        rs485_dir_DE : out std_logic    -- '1' para transmissor, '0' para receptor
    );
end entity RS485;

architecture RTL of RS485 is

    --! UART TX TYPE bit maps (See uart.h)
    constant TX_START_BIT : integer := 16;
    constant TX_DONE_BIT  : integer := 17;

    --! UART RX TYPE bit maps (See uart.h)
    constant RX_DONE_BIT : integer := 18;

    --! UART CONFIG TYPE bit maps (See uart.h)
    constant RX_ENABLE_BIT : integer := 23;

    -- Signals for TX
    type state_tx_type is (IDLE, MOUNT_BYTE, TRANSMIT, DONE);
    signal state_tx    : state_tx_type                 := IDLE;
    signal cnt_tx      : natural range 0 to 16         := 0;
    signal to_tx       : std_logic_vector(10 downto 0) := (others => '1');
    signal to_tx_p     : std_logic_vector(11 downto 0) := (others => '1');
    signal send_byte   : std_logic;
    signal send_byte_p : std_logic;

    -- Interal registers
    signal rx_register   : std_logic_vector(7 downto 0);
    signal tx_register   : std_logic_vector(7 downto 0);
    signal uart_register : std_logic_vector(31 downto 0);
    signal tx            : std_logic;
    signal tx_done       : std_logic;
    signal rx_done       : std_logic;

    -- Signals for RX
    type state_rx_type is (IDLE, READ_BYTE, DONE);
    signal state_rx : state_rx_type         := IDLE;
    signal cnt_rx   : natural range 0 to 16 := 0;

    -- Signals for baud rates
    signal baud_19200 : std_logic := '0';
    signal baud_09600 : std_logic := '0';
    signal baud_ready : std_logic := '0';

    -- Sinal interno para controle de direção RS485 [RS485]
    signal rs485_dir_int : std_logic := '0';

begin                                   --Baud Entrada = 38400

    ------------- Baud Rate 19200 --------------
    baud19200 : process(clk_baud) is
    begin
        if rising_edge(clk_baud) and (baud_19200 = '0') then
            baud_19200 <= '1';
        elsif rising_edge(clk_baud) and (baud_19200 = '1') then
            baud_19200 <= '0';
        end if;
    end process;

    -------------- Baud Rate 9600 --------------
    baud9600 : process(baud_19200) is
    begin
        if rising_edge(baud_19200) and (baud_09600 = '0') then
            baud_09600 <= '1';
        elsif rising_edge(baud_19200) and (baud_09600 = '1') then
            baud_09600 <= '0';
        end if;
    end process;

    -- force 9600
    baud_ready <= baud_09600;

    -- Input register
    process(clk, rst)
    begin
        if rst = '1' then
            ddata_r <= (others => '0');
        else
            if rising_edge(clk) then
                if (d_rd = '1') and (dcsel = MY_CHIPSELECT) then
                    if daddress(15 downto 0) = (MY_WORD_ADDRESS + x"0000") then
                        ddata_r <= uart_register;
                        -- ddata_r <= x"FF765432";
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- Output register
    process(clk, rst)
    begin
        if rst = '1' then
            uart_register <= (others => '0');
            tx_register   <= (others => '0');
        else
            if rising_edge(clk) then

                uart_register(15 downto 8)  <= rx_register;
                uart_register(TX_DONE_BIT)  <= tx_done;
                uart_register(RX_DONE_BIT)  <= rx_done;
                uart_register(TX_START_BIT) <= not tx_done;

                if (d_we = '1') and (dcsel = MY_CHIPSELECT) then
                    -- ativa a interrupção
                    if daddress(15 downto 0) = (MY_WORD_ADDRESS + x"0000") then
                        uart_register(31 downto 16) <= ddata_w(31 downto 16);
                        uart_register(7 downto 0)   <= ddata_w(7 downto 0);
                        tx_register                 <= ddata_w(7 downto 0);
                    end if;
                end if;
            end if;
        end if;
    end process;

    -------------------- TX --------------------

    -- Maquina de estado TX: Moore
    estado_tx : process(clk, rst) is
    begin
        if rst = '1' then
            state_tx <= IDLE;
        elsif rising_edge(clk) then
            case state_tx is
                when IDLE =>
                    -- Start transmission bit
                    if uart_register(TX_START_BIT) = '1' then

                        -- if uart_register(PARITY_BIT + 1) = '0' then
                        state_tx <= MOUNT_BYTE;
                        -- else
                        --     state_tx <= IDLE;
                        -- end if;
                    end if;
                when MOUNT_BYTE =>
                    if (cnt_tx > 1) then
                        state_tx <= MOUNT_BYTE;
                    else
                        state_tx <= TRANSMIT;
                    end if;

                when TRANSMIT =>
                    if (cnt_tx < 10) then
                        state_tx <= TRANSMIT;
                    else
                        state_tx <= DONE;
                    end if;

                when DONE =>
                    state_tx <= IDLE;
            end case;
        end if;
    end process;

    -- MEALY: transmission
    tx_proc : process(state_tx, tx_register, cnt_tx)
    begin
        tx_done     <= '0';
        send_byte   <= '0';
        send_byte_p <= '0';

        to_tx   <= (others => '1');
        to_tx_p <= (others => '1');

        case state_tx is
            when IDLE =>
                to_tx   <= (others => '1');
                tx_done <= '1';
            when MOUNT_BYTE =>
                if (cnt_tx = 0) then
                    to_tx <= "11" & tx_register & '0';
                end if;

            when TRANSMIT =>
                send_byte <= '1';
                to_tx     <= "11" & tx_register & '0';

            when DONE =>
                tx_done <= '1';

        end case;

    end process;

    tx_send : process(baud_ready)
    begin
        if rising_edge(baud_ready) then
            if send_byte = '1' then
                tx     <= to_tx(cnt_tx);
                cnt_tx <= cnt_tx + 1;
            elsif send_byte_p = '1' then
                tx     <= to_tx_p(cnt_tx);
                cnt_tx <= cnt_tx + 1;
            else
                tx     <= '1';
                cnt_tx <= 0;
            end if;
        end if;
    end process;

    -------------------- RX --------------------
    -- Maquina de estado RX: Moore
    estado_rx : process(clk, rst) is
    begin
        if rst = '1' then
            state_rx <= IDLE;
        elsif rising_edge(clk) then
            case state_rx is
                when IDLE =>
                    if uart_register(RX_ENABLE_BIT) = '1' then
                        if rx_out = '0' then
                            state_rx <= READ_BYTE;
                        else
                            state_rx <= IDLE;
                        end if;
                    end if;
                when READ_BYTE =>
                    if (cnt_rx < 10) then
                        state_rx <= READ_BYTE;
                    else
                        state_rx <= DONE;
                    end if;
                when DONE =>
                    state_rx <= IDLE;

            end case;
        end if;
    end process;

    -- Maquina MEALY: transmission
    rx_proc : process(state_rx)
    begin
        rx_done <= '0';

        case state_rx is
            when IDLE =>
                rx_done <= '1';
            when READ_BYTE =>

            when DONE =>
                rx_done <= '1';

        end case;
    end process;

    rx_receive : process(rst, baud_ready, rx_done)
        variable from_rx : std_logic_vector(9 downto 0);
    begin
        if rst = '1' then
            rx_register <= (others => '0');
            cnt_rx      <= 0;
            from_rx     := (others => '0');
        else
            if rx_done = '0' then
                if rising_edge(baud_ready) then
                    from_rx(cnt_rx) := rx_out;
                    cnt_rx          <= cnt_rx + 1;
                    if cnt_rx = 8 then
                        rx_register <= from_rx(8 downto 1);
                    end if;
                end if;
            else
                cnt_rx <= 0;
            end if;
        end if;
    end process;

    -- Atribuição para o controle de direção RS485 [RS485]
    rs485_dir_DE <= rs485_dir_int;

    -- Processo para atualizar o controle de direção com base na máquina de estados do TX [RS485]
    process(clk, rst)
    begin
        if rst = '1' then
            rs485_dir_int <= '0';       -- Modo recepção por padrão
        elsif rising_edge(clk) then
            if state_tx /= IDLE then
                rs485_dir_int <= '1';   -- Ativa transmissão sempre que state_tx não estiver em IDLE, estiver transmitindo
            else
                rs485_dir_int <= '0';   -- Caso contrario volta para o modo recepção
            end if;
        end if;
    end process;

    tx_out <= tx;

end architecture RTL;
