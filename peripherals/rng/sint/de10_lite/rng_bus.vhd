-------------------------------------------------------------------
-- Name        : rng_bus.vhd
-- Author      : Elisa Anes Romero
-- Version     : 0.1
-- Copyright   : Renan, Departamento de Eletrônica, Florianópolis, IFSC
-- Description : Random number generator bus
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rng_bus is
    generic (
        MY_CHIPSELECT   : std_logic_vector(1 downto 0) := "10";
        MY_WORD_ADDRESS : unsigned(15 downto 0) := x"0640"; -- Endereço base deste periférico
        DADDRESS_BUS_SIZE : integer := 32
    );
    port (
        -- Sinais do Barramento (Conectam no Softcore)
        clk      : in std_logic;
        rst      : in std_logic;
        
        -- Barramento de Dados/Endereços
        daddress : in  unsigned(DADDRESS_BUS_SIZE-1 downto 0);  -- Endereço vindo do processador
        ddata_w  : in std_logic_vector(31 downto 0);            -- Dado vindo do processador (Escrita)
        ddata_r  : out std_logic_vector(31 downto 0);           -- Dado indo para o processador (Leitura)
        
        -- Sinais de Controle
        d_we     : in std_logic;                    -- Write Enable (1 = escrever)
        d_rd     : in std_logic;                    -- Read Enable (1 = ler)
        dcsel    : in std_logic_vector(1 downto 0); -- Chip Select do grupo de periféricos
        dmask    : in std_logic_vector(3 downto 0)  -- Máscara de bytes
    );
end entity rng_bus;

architecture rtl of rng_bus is

    signal rng_data : std_logic_vector(31 downto 0);
    signal chip_enable : std_logic;


begin

    -- O sinal rng_select vai para '1' APENAS se:
    -- 1) O grupo de periféricos estiver selecionado (dcsel)
    -- 2) Endereço bater com o endereço base (MY_WORD_ADDRESS)

    process(rst,clk)
    begin
        if rst = '1' then
            ddata_r <= (others =>'0');
            chip_enable <= '0';
        else
            if rising_edge(clk) then
                chip_enable <= '0';
                if(d_rd = '1') and (dcsel = MY_CHIPSELECT) then
                    if daddress(15 downto 0) = MY_WORD_ADDRESS then
                        ddata_r <= rng_data;
                        chip_enable <= '1';
                    end if;
                end if;
            end if;
        end if;
    end process;    

    ---------------------------------------------------------------------------
    -- 2. Instanciação do Componente RNG

    dut_rng: entity work.rng
        port map (
            clk          => clk,
            rst          => rst,
            read_data    => rng_data,
            -- Controle
            chip_select  => chip_enable,
            addr         => "00" 
        );

end architecture rtl;

