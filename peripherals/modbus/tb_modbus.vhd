-------------------------------------------------------------------
-- Name        : tb_modbus.vhd
-- Author      : Guilherme da Costa Franco
-- Description : Testbench for Modbus RTU Implementation
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_modbus is
end entity tb_modbus;

architecture testbench of tb_modbus is

    -- Component declaration
    component modbus_rtu is
        generic(
            MY_CHIPSELECT     : std_logic_vector(1 downto 0);
            MY_WORD_ADDRESS   : unsigned(15 downto 0);
            DADDRESS_BUS_SIZE : integer;
            SLAVE_ADDRESS     : std_logic_vector(7 downto 0)
        );
        port(
            clk         : in  std_logic;
            rst         : in  std_logic;
            daddress    : in  unsigned(DADDRESS_BUS_SIZE - 1 downto 0);
            ddata_w     : in  std_logic_vector(31 downto 0);
            ddata_r     : out std_logic_vector(31 downto 0);
            d_we        : in  std_logic;
            d_rd        : in  std_logic;
            dcsel       : in  std_logic_vector(1 downto 0);
            dmask       : in  std_logic_vector(3 downto 0);
            debug_state : out std_logic_vector(3 downto 0);
            debug_crc   : out std_logic_vector(15 downto 0)
        );
    end component;

    -- Clock period
    constant CLK_PERIOD : time := 20 ns;  -- 50 MHz

    -- Signals
    signal clk         : std_logic := '0';
    signal rst         : std_logic := '1';
    signal daddress    : unsigned(31 downto 0) := (others => '0');
    signal ddata_w     : std_logic_vector(31 downto 0) := (others => '0');
    signal ddata_r     : std_logic_vector(31 downto 0);
    signal d_we        : std_logic := '0';
    signal d_rd        : std_logic := '0';
    signal dcsel       : std_logic_vector(1 downto 0) := "10";
    signal dmask       : std_logic_vector(3 downto 0) := "1111";
    signal debug_state : std_logic_vector(3 downto 0);
    signal debug_crc   : std_logic_vector(15 downto 0);
    
    -- Test control
    signal test_done   : boolean := false;
    
    -- Endereços base
    constant BASE_ADDR : unsigned(15 downto 0) := x"0040";

begin

    -- DUT instantiation
    dut : modbus_rtu
        generic map(
            MY_CHIPSELECT     => "10",
            MY_WORD_ADDRESS   => x"0040",
            DADDRESS_BUS_SIZE => 32,
            SLAVE_ADDRESS     => x"01"
        )
        port map(
            clk         => clk,
            rst         => rst,
            daddress    => daddress,
            ddata_w     => ddata_w,
            ddata_r     => ddata_r,
            d_we        => d_we,
            d_rd        => d_rd,
            dcsel       => dcsel,
            dmask       => dmask,
            debug_state => debug_state,
            debug_crc   => debug_crc
        );

    -- Clock generation
    clk_process : process
    begin
        while not test_done loop
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;



    -- Stimulus process
    stimulus : process
        -- Procedure para escrever no barramento
        procedure write_bus(
            constant addr : in unsigned(15 downto 0);
            constant data : in std_logic_vector(31 downto 0)
        ) is
        begin
            daddress <= resize(addr, 32);
            ddata_w <= data;
            d_we <= '1';
            wait for CLK_PERIOD;
            d_we <= '0';
            wait for CLK_PERIOD;
        end procedure;

        -- Procedure para ler do barramento
        procedure read_bus(
            constant addr : in unsigned(15 downto 0)
        ) is
        begin
            daddress <= resize(addr, 32);
            d_rd <= '1';
            wait for CLK_PERIOD;
            d_rd <= '0';
            wait for CLK_PERIOD;
        end procedure;

    begin
        -- Inicialização
        report "===== Iniciando Teste do Modbus RTU =====";
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 100 ns;

        report "===== Teste 1: Verificação de Reset =====";
        read_bus(BASE_ADDR + x"0000");
        assert ddata_r = x"00000000" 
            report "Erro: Status register não está em zero após reset" 
            severity error;
        wait for 100 ns;

        report "===== Teste 2: Escrita em Holding Registers =====";
        -- Escrever valores nos holding registers
        write_bus(BASE_ADDR + x"0003", x"CAFEBEEF");
        write_bus(BASE_ADDR + x"0004", x"DEAD1234");
        wait for 100 ns;
        
        -- Ler de volta para verificar
        read_bus(BASE_ADDR + x"0003");
        wait for CLK_PERIOD;
        assert ddata_r = x"CAFEBEEF" 
            report "Erro: Holding registers 0-1 não gravaram corretamente" 
            severity error;
        
        read_bus(BASE_ADDR + x"0004");
        wait for CLK_PERIOD;
        assert ddata_r = x"DEAD1234" 
            report "Erro: Holding registers 2-3 não gravaram corretamente" 
            severity error;
        wait for 100 ns;

        report "===== Teste 3: Simulação de Recepção Modbus =====";
        report "Simulando frame: [Addr=01][Func=03][DataH=00][DataL=01][CRC]";
        
        -- Simular recepção de um frame Modbus
        -- Endereço do escravo
        write_bus(BASE_ADDR + x"0010", x"00000001");
        
        -- Função 03 (Read Holding Registers)
        write_bus(BASE_ADDR + x"0011", x"00000003");
        
        -- Endereço do registro (High byte)
        write_bus(BASE_ADDR + x"0012", x"00000000");
        
        -- Quantidade de registros (Low byte)
        write_bus(BASE_ADDR + x"0013", x"00000001");
        wait for 100 ns;

        report "===== Teste 4: Habilitando Modbus e Iniciando RX =====";
        -- Habilitar Modbus e iniciar recepção
        write_bus(BASE_ADDR + x"0000", x"00000005");  -- Enable + Start RX
        wait for 500 ns;

        -- Verificar status
        read_bus(BASE_ADDR + x"0000");
        report "Status register lido";
        
        -- Verificar dados recebidos
        read_bus(BASE_ADDR + x"0002");
        report "Funcao e endereco recebidos";
        wait for 100 ns;

        report "===== Teste 5: Simulação de Frame com CRC =====";
        -- Frame: 01 03 00 01 com CRC calculado
        -- CRC16 Modbus para [01 03 00 01] = 0xD5CA (aproximado)
        
        write_bus(BASE_ADDR + x"0010", x"00000001"); -- Addr
        write_bus(BASE_ADDR + x"0011", x"00000006"); -- Func 06 (Write)
        write_bus(BASE_ADDR + x"0012", x"00000000"); -- Register addr
        write_bus(BASE_ADDR + x"0013", x"000000FF"); -- Value to write
        wait for 100 ns;

        -- Iniciar processamento
        write_bus(BASE_ADDR + x"0000", x"00000005");
        wait for 1000 ns;

        -- Verificar se processou
        read_bus(BASE_ADDR + x"0000");
        report "Status apos processamento lido";
        wait for 100 ns;

        report "===== Teste 6: Verificação de Endereço Inválido =====";
        write_bus(BASE_ADDR + x"0010", x"00000099"); -- Addr inválido
        write_bus(BASE_ADDR + x"0011", x"00000003");
        write_bus(BASE_ADDR + x"0012", x"00000000");
        write_bus(BASE_ADDR + x"0013", x"00000001");
        
        write_bus(BASE_ADDR + x"0000", x"00000005");
        wait for 500 ns;
        
        read_bus(BASE_ADDR + x"0000");
        report "Status com endereco invalido lido";
        wait for 100 ns;

        report "===== Teste 7: Leitura de Debug =====";
        report "Debug State e CRC visiveis no Wave";
        wait for 100 ns;

        report "===== TODOS OS TESTES CONCLUIDOS =====";
        test_done <= true;
        wait;
    end process;

    -- Monitor process
    monitor : process(clk)
    begin
        if rising_edge(clk) then
            if debug_state /= "0000" then
                report "Estado: " & integer'image(to_integer(unsigned(debug_state)));
            end if;
        end if;
    end process;

end architecture testbench;
