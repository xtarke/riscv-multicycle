library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RS485 is
    generic(
        --! Chip selec
        MY_CHIPSELECT     : std_logic_vector(1 downto 0) := "10";
        MY_WORD_ADDRESS   : unsigned(15 downto 0)        := x"0170";
        DADDRESS_BUS_SIZE : integer                      := 32
    );

    port(
        clk          : in  std_logic;
        rst          : in  std_logic;
        clk_baud     : in  std_logic;
        -- Core data bus signals
        daddress     : in  unsigned(DADDRESS_BUS_SIZE - 1 downto 0);
        ddata_w      : in  std_logic_vector(31 downto 0);
        ddata_r      : out std_logic_vector(31 downto 0);
        d_we         : in  std_logic;
        d_rd         : in  std_logic;
        dcsel        : in  std_logic_vector(1 downto 0); --! Chip select 
        -- ToDo: Module should mask bytes (Word, half word and byte access)
        dmask        : in  std_logic_vector(3 downto 0); --! Byte enable mask

        -- hardware input/output signals
        tx_out       : out std_logic;
        rx_out       : in  std_logic;
        interrupts   : out std_logic_vector(1 downto 0);
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
    constant RX_ENABLE_BIT     : integer := 23;
    constant IRQ_RX_ENABLE_BIT : integer := 24;

    constant BAUD_RATE_BIT : integer := 19; --! Bits 19 and 20
    constant PARITY_BIT    : integer := 21; --! Bits 21 and 22

    --! BUFFER CONFIG TYPE bit maps (See uart.h)
    constant IRQ_MODE_BIT  : integer := 31; --! Bit 31
    constant NUM_BYTES_IRQ : integer := 7; --! Bits 7 a 0
    constant BYTE_FINAL    : integer := 15; --! Bits 15 and 8

    -- Signals for TX
    type state_tx_type is (IDLE, MOUNT_BYTE, TRANSMIT, MOUNT_BYTE_PARITY, TRANSMIT_PARITY, DONE);
    signal state_tx    : state_tx_type                 := IDLE;
    signal cnt_tx      : integer                       := 0;
    signal to_tx       : std_logic_vector(10 downto 0) := (others => '1');
    signal to_tx_p     : std_logic_vector(11 downto 0) := (others => '1');
    signal send_byte   : std_logic;
    signal send_byte_p : std_logic;

    -- Interal registers
    signal config_register : std_logic_vector(31 downto 0);
    signal rx_register     : std_logic_vector(7 downto 0);
    signal tx_register     : std_logic_vector(7 downto 0);

    signal uart_register : std_logic_vector(31 downto 0);

    signal buffer_register : std_logic_vector(31 downto 0);
    signal buffer_mode     : std_logic;
    signal buffer_byte     : std_logic_vector(7 downto 0);

    signal tx : std_logic;

    signal tx_done : std_logic;
    signal rx_done : std_logic;

    -- Signals for RX
    type state_rx_type is (IDLE, READ_BYTE, DONE);
    signal state_rx      : state_rx_type := IDLE;
    signal cnt_rx        : integer       := 0;
    signal byte_received : std_logic;
    -- Signal for Buffer RX
    signal byte_read     : std_logic;
    signal cnt_rx_buffer : unsigned(2 downto 0);

    -- Signals for baud rates
    signal baud_19200 : std_logic := '0';
    signal baud_09600 : std_logic := '0';
    signal baud_04800 : std_logic := '0';
    signal baud_ready : std_logic := '0';

    -- Signals for parity
    signal parity : std_logic := '0';
    signal number : integer   := 0;

    -- Interrupt signal
    signal input_data   : std_logic;
    signal rx_cmp_irq   : std_logic;
    signal interrupt_en : std_logic := '0';

    -- Sinal interno para controle de direção RS485 [RS485]
    signal rs485_dir_int : std_logic := '0';

    --Declaracao do vetor de buffer RX
    type buffer_in is array (0 to 7) of std_logic_vector(7 downto 0);
    signal buffer_rx : buffer_in := (
        x"00", x"00", x"00", x"00",
        x"00", x"00", x"00", x"00");

    ------------ Function Count Ones -----------
    function count_ones(s : std_logic_vector) return integer is
        variable temp : natural := 0;
    begin
        for i in s'range loop
            if s(i) = '1' then
                temp := temp + 1;
            end if;
        end loop;
        return temp;
    end function count_ones;

    ----------- Function Parity Value ----------
    function parity_val(s : integer; setup : std_logic) return std_logic is
        variable temp : std_logic := '0';
    begin
        if ((s mod 2) = 0) and (setup = '0') then --Paridade ativada impar
            temp := '0';
        elsif ((s mod 2) = 0) and (setup = '1') then --Paridade ativada par
            temp := '1';
        elsif ((s mod 2) = 1) and (setup = '0') then --Paridade ativada impar
            temp := '1';
        elsif ((s mod 2) = 1) and (setup = '1') then --Paridade ativada par
            temp := '0';
        end if;
        return temp;
    end function parity_val;

begin                                   --Baud Entrada = 38400

    ------------- Baud Rate 19200 --------------
    baud19200 : process(clk_baud, baud_19200) is
    begin
        if rising_edge(clk_baud) and (baud_19200 = '0') then
            baud_19200 <= '1';
        elsif rising_edge(clk_baud) and (baud_19200 = '1') then
            baud_19200 <= '0';
        end if;
    end process;

    -------------- Baud Rate 9600 --------------
    baud9600 : process(baud_19200, baud_09600) is
    begin
        if rising_edge(baud_19200) and (baud_09600 = '0') then
            baud_09600 <= '1';
        elsif rising_edge(baud_19200) and (baud_09600 = '1') then
            baud_09600 <= '0';
        end if;
    end process;

    -------------- Baud Rate 4800 --------------
    baud4800 : process(baud_09600, baud_04800) is
    begin
        if rising_edge(baud_09600) and (baud_04800 = '0') then
            baud_04800 <= '1';
        elsif rising_edge(baud_09600) and (baud_04800 = '1') then
            baud_04800 <= '0';
        end if;
    end process;

    -------------- Baud Rate Select -------------
    baudselect : process(uart_register(BAUD_RATE_BIT+1 downto BAUD_RATE_BIT), baud_04800, baud_09600, baud_19200, clk_baud) is
    begin
        case uart_register(BAUD_RATE_BIT + 1 downto BAUD_RATE_BIT) is
            when "00" =>
                baud_ready <= clk_baud;
            when "01" =>
                baud_ready <= baud_19200;
            when "10" =>
                baud_ready <= baud_09600;
            when "11" =>
                baud_ready <= baud_04800;
            when others =>
                baud_ready <= baud_09600;
        end case;
    end process;

    -- Input register
    process(clk, rst)
    begin
        if rst = '1' then
            ddata_r <= (others => '0');
        else
            if rising_edge(clk) then
                if (d_rd = '1') and (dcsel = MY_CHIPSELECT) then
                    --! Tx register: supports byte read
                    if daddress(15 downto 0) = (MY_WORD_ADDRESS + x"0000") then
                        ddata_r <= (others => '0');
                        case dmask is
                            when "1111" => ddata_r <= uart_register;
                            when "0011" => ddata_r(15 downto 0) <= uart_register(15 downto 0);
                            when "1100" => ddata_r(15 downto 0) <= uart_register(31 downto 16);
                            when "0001" => ddata_r(7 downto 0) <= uart_register(7 downto 0);
                            when "0010" => ddata_r(7 downto 0) <= uart_register(15 downto 8);
                            when "0100" => ddata_r(7 downto 0) <= uart_register(23 downto 16);
                            when "1000" => ddata_r(7 downto 0) <= uart_register(31 downto 24);
                            when others =>
                        end case;

                    elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + x"0001") then
                        ddata_r <= (others => '0');
                        case dmask is
                            when "1111" => ddata_r <= buffer_rx(3) & buffer_rx(2) & buffer_rx(1) & buffer_rx(0);
                            when "0011" => ddata_r(15 downto 0) <= buffer_rx(1) & buffer_rx(0);
                            when "1100" => ddata_r(15 downto 0) <= buffer_rx(3) & buffer_rx(2);
                            when "0001" => ddata_r(7 downto 0) <= buffer_rx(0);
                            when "0010" => ddata_r(7 downto 0) <= buffer_rx(1);
                            when "0100" => ddata_r(7 downto 0) <= buffer_rx(2);
                            when "1000" => ddata_r(7 downto 0) <= buffer_rx(3);
                            when others =>
                        end case;

                    elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + x"0002") then
                        ddata_r <= (others => '0');
                        case dmask is
                            when "1111" => ddata_r <= buffer_rx(7) & buffer_rx(6) & buffer_rx(5) & buffer_rx(4);
                            when "0011" => ddata_r(15 downto 0) <= buffer_rx(5) & buffer_rx(4);
                            when "1100" => ddata_r(15 downto 0) <= buffer_rx(7) & buffer_rx(6);
                            when "0001" => ddata_r(7 downto 0) <= buffer_rx(4);
                            when "0010" => ddata_r(7 downto 0) <= buffer_rx(5);
                            when "0100" => ddata_r(7 downto 0) <= buffer_rx(6);
                            when "1000" => ddata_r(7 downto 0) <= buffer_rx(7);
                            when others =>
                        end case;

                    elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + x"0003") then
                        ddata_r <= (others => '0');
                        case dmask is
                            when "1111" => ddata_r <= buffer_register;
                            when "0011" => ddata_r(15 downto 0) <= buffer_register(15 downto 0);
                            when "1100" => ddata_r(15 downto 0) <= buffer_register(31 downto 16);
                            when "0001" => ddata_r(7 downto 0) <= buffer_register(7 downto 0);
                            when "0010" => ddata_r(7 downto 0) <= buffer_register(15 downto 8);
                            when "0100" => ddata_r(7 downto 0) <= buffer_register(23 downto 16);
                            when "1000" => ddata_r(7 downto 0) <= buffer_register(31 downto 24);
                            when others =>
                        end case;
                    end if;
                end if;
            end if;
        end if;
    end process;

    tx_register(7 downto 0) <= uart_register(7 downto 0); --! Byte to transmit

    -- Output register
    process(clk, rst)
    begin
        if rst = '1' then
            -- tx_register <= (others => '0');
            uart_register   <= (others => '0');
            buffer_register <= (others => '0');
        elsif rising_edge(clk) then

            -- Set/Reset register to detect writes in TX_START_BIT
            uart_register(TX_START_BIT) <= not tx_done;
            uart_register(15 downto 8)  <= rx_register;
            uart_register(RX_DONE_BIT)  <= rx_done;

            if (d_we = '1') and (dcsel = MY_CHIPSELECT) then

                --! Tx register supports byte write
                if daddress(15 downto 0) = (MY_WORD_ADDRESS + x"0000") then
                    case dmask is
                        when "1111" =>
                            uart_register <= ddata_w(31 downto 0);
                        when "0011" =>
                            uart_register(15 downto 0) <= ddata_w(15 downto 0);
                        when "1100" =>
                            uart_register(31 downto 16) <= ddata_w(15 downto 0);
                        when "0001" =>
                            uart_register(7 downto 0) <= ddata_w(7 downto 0);
                        when "0010" =>
                            uart_register(15 downto 8) <= ddata_w(7 downto 0);
                        when "0100" =>
                            uart_register(23 downto 16) <= ddata_w(7 downto 0);
                        when "1000" =>
                            uart_register(31 downto 24) <= ddata_w(7 downto 0);
                        when others =>
                    end case;

                elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + x"0003") then
                    case dmask is
                        when "1111" =>
                            buffer_register <= ddata_w(31 downto 0);
                        when "0011" =>
                            buffer_register(15 downto 0) <= ddata_w(15 downto 0);
                        when "1100" =>
                            buffer_register(31 downto 16) <= ddata_w(15 downto 0);
                        when "0001" =>
                            buffer_register(7 downto 0) <= ddata_w(7 downto 0);
                        when "0010" =>
                            buffer_register(15 downto 8) <= ddata_w(7 downto 0);
                        when "0100" =>
                            buffer_register(23 downto 16) <= ddata_w(7 downto 0);
                        when "1000" =>
                            buffer_register(31 downto 24) <= ddata_w(7 downto 0);
                        when others =>
                    end case;
                end if;
            end if;

            -- Keep Done flag
            uart_register(TX_DONE_BIT) <= tx_done;

        end if;
    end process;

    ---------------- Parity Setup ---------------
    parity_set : process(uart_register(PARITY_BIT+1 downto PARITY_BIT), number, tx_register) is
    begin
        number <= 0;
        parity <= '0';

        if uart_register(PARITY_BIT + 1) = '1' then
            number <= count_ones(tx_register(7 downto 0));
            parity <= parity_val(number, uart_register(PARITY_BIT));
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

                        if uart_register(PARITY_BIT + 1) = '1' then
                            state_tx <= MOUNT_BYTE_PARITY;
                        elsif uart_register(PARITY_BIT + 1) = '0' then
                            state_tx <= MOUNT_BYTE;
                        else
                            state_tx <= IDLE;
                        end if;
                    end if;
                when MOUNT_BYTE =>
                    if (cnt_tx > 1) then
                        state_tx <= MOUNT_BYTE;
                    else
                        state_tx <= TRANSMIT;
                    end if;
                --state_tx <= TRANSMIT;
                when MOUNT_BYTE_PARITY =>
                    if (cnt_tx > 1) then
                        state_tx <= MOUNT_BYTE_PARITY;
                    else
                        state_tx <= TRANSMIT_PARITY;
                    end if;
                --state_tx <= TRANSMIT_PARITY;
                when TRANSMIT =>
                    if (cnt_tx < 10) then
                        state_tx <= TRANSMIT;
                    else
                        state_tx <= DONE;
                    end if;
                when TRANSMIT_PARITY =>
                    if (cnt_tx < 11) then
                        state_tx <= TRANSMIT_PARITY;
                    else
                        state_tx <= DONE;
                    end if;

                when DONE =>
                    state_tx <= IDLE;
            end case;
        end if;
    end process;

    -- MEALY: transmission
    tx_proc : process(state_tx, tx_register, parity)
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
                    to_tx <= "11" & tx_register(7 downto 0) & '0';
                end if;

            when MOUNT_BYTE_PARITY =>
                if (cnt_tx = 0) then
                    to_tx_p <= "11" & tx_register(7 downto 0) & parity & '0';
                end if;

            when TRANSMIT =>
                send_byte <= '1';
                to_tx     <= "11" & tx_register(7 downto 0) & '0';

            when TRANSMIT_PARITY =>
                send_byte_p <= '1';
                to_tx_p     <= "11" & tx_register(7 downto 0) & parity & '0';

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
    rx_proc : process(state_rx, uart_register(RX_ENABLE_BIT))
    begin
        byte_received <= '0';
        rx_done       <= '0';
        byte_read     <= '0';
        case state_rx is
            when IDLE =>
                rx_done <= not uart_register(RX_ENABLE_BIT);
            when READ_BYTE =>
                byte_received <= '1';
            when DONE =>
                rx_done   <= '1';
                byte_read <= '1';
        end case;
    end process;

    rx_buffer_config : process(rst, clk)
    begin
        if rst = '1' then
            buffer_mode <= '0';
            buffer_byte <= (others => '0');
        elsif rising_edge(clk) then
            case uart_register(IRQ_MODE_BIT) is
                when '0' =>
                    buffer_mode <= '0';
                    buffer_byte <= buffer_register(NUM_BYTES_IRQ downto NUM_BYTES_IRQ - 7);
                when '1' =>
                    buffer_mode <= '1';
                    buffer_byte <= buffer_register(BYTE_FINAL downto BYTE_FINAL - 7);
                when others =>
            end case;
        end if;
    end process;

    rx_buffer_receive : process(rst, clk)
        variable cnt_rx_irq : unsigned(2 downto 0);
    begin
        if rst = '1' then
            cnt_rx_buffer <= (others => '0');
            rx_cmp_irq    <= '0';
            cnt_rx_irq    := (others => '0');
            for i in 0 to 7 loop
                buffer_rx(i) <= (others => '0');
            end loop;
        elsif rising_edge(clk) then
            rx_cmp_irq <= '0';
            if byte_read = '1' then
                buffer_rx(to_integer(cnt_rx_buffer)) <= rx_register;
                case buffer_mode is
                    when '0' => if cnt_rx_irq = unsigned(buffer_byte(2 downto 0)) - 1 then
                            --proc irq handler
                            cnt_rx_irq := "111";
                            rx_cmp_irq <= '1';
                        end if;
                    when '1' =>
                        if rx_register = buffer_byte then
                            --proc irq handler
                            rx_cmp_irq <= '1';
                        end if;
                    when others =>
                end case;
                cnt_rx_irq    := cnt_rx_irq + 1;
                cnt_rx_buffer <= cnt_rx_buffer + 1;
            end if;
        end if;
    end process;

    rx_receive : process(rst, baud_ready, byte_received)
        variable from_rx : std_logic_vector(9 downto 0);
    begin
        if rst = '1' then
            rx_register <= (others => '0');
            cnt_rx      <= 0;
            from_rx     := (others => '0');
        else
            if byte_received = '1' then
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

    interrupt_proc : process(clk, rst)
    begin
        if rst = '1' then
            interrupts <= (others => '0');
        elsif rising_edge(clk) then
            interrupts(1) <= '0';

            if input_data = '0' and rx_cmp_irq = '1' and uart_register(IRQ_RX_ENABLE_BIT) = '1' then
                interrupts(0) <= '1';
            else
                interrupts(0) <= '0';
            end if;
            input_data <= rx_cmp_irq;
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
