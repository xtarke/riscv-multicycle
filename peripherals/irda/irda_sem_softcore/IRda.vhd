library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity IR_RECEIVE is
    Port (
        iCLK         : in  STD_LOGIC;        -- Clock de 50 MHz
        iRST_n       : in  STD_LOGIC;        -- Reset (ativo baixo)
        iIRDA        : in  STD_LOGIC;        -- Sinal de entrada IR
        oDATA_READY  : out STD_LOGIC;        -- Flag de dados prontos
        oDATA        : out STD_LOGIC_VECTOR(31 downto 0)  -- Dados decodificados (32 bits)
    );
end IR_RECEIVE;

architecture Behavioral of IR_RECEIVE is
    -- Definição dos estados
    type state_type is (IDLE, GUIDANCE, DATAREAD);
    signal state : state_type := IDLE;

    -- Constantes para contagem de tempo
    constant IDLE_HIGH_DUR     : integer := 262143;  -- 5.24 ms
    constant GUIDE_LOW_DUR     : integer := 230000;  -- 4.60 ms
    constant GUIDE_HIGH_DUR    : integer := 210000;  -- 4.20 ms
    constant DATA_HIGH_DUR     : integer := 41500;   -- 0.83 ms
    constant BIT_AVAILABLE_DUR : integer := 20000;   -- 0.40 ms

    -- Sinais internos
    signal idle_count      : integer range 0 to 262143 := 0;
    signal idle_count_flag : STD_LOGIC := '0';
    signal state_count     : integer range 0 to 210000 := 0;
    signal state_count_flag: STD_LOGIC := '0';
    signal data_count      : integer range 0 to 262143 := 0;
    signal data_count_flag : STD_LOGIC := '0';
    signal bitcount        : integer range 0 to 63 := 0;
    signal data            : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal data_buf        : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal data_ready      : STD_LOGIC := '0';
begin
    -- Atribuição da saída
    oDATA_READY <= data_ready;

    -- Contador para o estado IDLE
    process(iCLK, iRST_n)
    begin
        if iRST_n = '0' then
            idle_count <= 0;
        elsif rising_edge(iCLK) then
            if idle_count_flag = '1' then
                idle_count <= idle_count + 1;
            else
                idle_count <= 0;
            end if;
        end if;
    end process;

    -- Flag do contador IDLE
    process(iCLK, iRST_n)
    begin
        if iRST_n = '0' then
            idle_count_flag <= '0';
        elsif rising_edge(iCLK) then
            if (state = IDLE) and (iIRDA = '0') then
                idle_count_flag <= '1';
            else
                idle_count_flag <= '0';
            end if;
        end if;
    end process;

    -- Contador para o estado GUIDANCE
    process(iCLK, iRST_n)
    begin
        if iRST_n = '0' then
            state_count <= 0;
        elsif rising_edge(iCLK) then
            if state_count_flag = '1' then
                state_count <= state_count + 1;
            else
                state_count <= 0;
            end if;
        end if;
    end process;

    -- Flag do contador GUIDANCE
    process(iCLK, iRST_n)
    begin
        if iRST_n = '0' then
            state_count_flag <= '0';
        elsif rising_edge(iCLK) then
            if (state = GUIDANCE) and (iIRDA = '1') then
                state_count_flag <= '1';
            else
                state_count_flag <= '0';
            end if;
        end if;
    end process;

    -- Contador para o estado DATAREAD
    process(iCLK, iRST_n)
    begin
        if iRST_n = '0' then
            data_count <= 0;
        elsif rising_edge(iCLK) then
            if data_count_flag = '1' then
                data_count <= data_count + 1;
            else
                data_count <= 0;
            end if;
        end if;
    end process;

    -- Flag do contador DATAREAD
    process(iCLK, iRST_n)
    begin
        if iRST_n = '0' then
            data_count_flag <= '0';
        elsif rising_edge(iCLK) then
            if (state = DATAREAD) and (iIRDA = '1') then
                data_count_flag <= '1';
            else
                data_count_flag <= '0';
            end if;
        end if;
    end process;

    -- Contador de bits (bitcount)
    process(iCLK, iRST_n)
    begin
        if iRST_n = '0' then
            bitcount <= 0;
        elsif rising_edge(iCLK) then
            if state = DATAREAD then
                if data_count = BIT_AVAILABLE_DUR then
                    bitcount <= bitcount + 1;
                end if;
            else
                bitcount <= 0;
            end if;
        end if;
    end process;

    -- Máquina de estados
    process(iCLK, iRST_n)
    begin
        if iRST_n = '0' then
            state <= IDLE;
        elsif rising_edge(iCLK) then
            case state is
                when IDLE =>
                    if idle_count > GUIDE_LOW_DUR then
                        state <= GUIDANCE;
                    end if;
                when GUIDANCE =>
                    if state_count > GUIDE_HIGH_DUR then
                        state <= DATAREAD;
                    end if;
                when DATAREAD =>
                    if (data_count >= IDLE_HIGH_DUR) or (bitcount >= 33) then
                        state <= IDLE;
                    end if;
                when others =>
                    state <= IDLE;
            end case;
        end if;
    end process;

    -- Decodificação dos dados
    process(iCLK, iRST_n)
    begin
        if iRST_n = '0' then
            data <= (others => '0');
        elsif rising_edge(iCLK) then
            if state = DATAREAD then
                if data_count >= DATA_HIGH_DUR then
                    data(bitcount - 1) <= '1';
                end if;
            else
                data <= (others => '0');
            end if;
        end if;
    end process;

    -- Flag de dados prontos
    process(iCLK, iRST_n)
    begin
        if iRST_n = '0' then
            data_ready <= '0';
        elsif rising_edge(iCLK) then
            if bitcount = 32 then
                if data(31 downto 24) = not data(23 downto 16) then
                    data_buf <= data;
                    data_ready <= '1';
                else
                    data_ready <= '0';
                end if;
            else
                data_ready <= '0';
            end if;
        end if;
    end process;

    -- Saída dos dados
    process(iCLK, iRST_n)
    begin
        if iRST_n = '0' then
            oDATA <= (others => '0');
        elsif rising_edge(iCLK) then
            if data_ready = '1' then
                oDATA <= data_buf;
            end if;
        end if;
    end process;

end Behavioral;