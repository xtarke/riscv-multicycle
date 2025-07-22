library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity led_controller_wrapper is
    generic(
        MY_CHIPSELECT     : std_logic_vector(1 downto 0) := "10";
        MY_WORD_ADDRESS   : unsigned(15 downto 0)        := x"0190";
        DADDRESS_BUS_SIZE : integer                      := 32
    );
    port(
        clk      : in  std_logic;
        clk_50   : in std_logic;
        rst      : in  std_logic;

        -- Barramento de dados do softcore
        daddress : in  unsigned(DADDRESS_BUS_SIZE - 1 downto 0);
        ddata_w  : in  std_logic_vector(31 downto 0);
        --ddata_r  : out	std_logic_vector(31 downto 0);
        d_we     : in  std_logic;
        --d_rd     : in std_logic;
        dcsel    : in  std_logic_vector(1 downto 0);
        dmask    : in  std_logic_vector(3 downto 0);

        -- hardware input/output signals 
        dout     : out std_logic
    );
end entity;

architecture rtl of led_controller_wrapper is

    -- Sinais internos para o controlador
    signal ctrl_start    : std_logic := '0';
    signal ctrl_restart  : std_logic := '0';
    signal ctrl_din      : std_logic_vector(23 downto 0) := (others => '0');

    -- Instância do controlador
    component controlador
        port (
            clk     : in  std_logic;
            reset   : in  std_logic;
            start   : in  std_logic;
            restart : in  std_logic;
            din     : in  std_logic_vector(23 downto 0);
            dout    : out std_logic
        );
    end component;

begin

    -- Instancia o controlador WS2812
    led_ctrl_inst : controlador
        port map (
            clk     => clk_50,
            reset   => rst,
            start   => ctrl_start,
            restart => ctrl_restart,
            din     => ctrl_din,
            dout    => dout
        );

    -- Processo de escrita
    process(clk, rst)
    begin
        if rst = '1' then
            ctrl_start   <= '0';
            ctrl_restart <= '0';
            ctrl_din     <= (others => '0');
        elsif rising_edge(clk) then
            if (d_we = '1') and (dcsel = MY_CHIPSELECT) then
                if daddress(15 downto 0) = MY_WORD_ADDRESS then
                    ctrl_start   <= ddata_w(0);
                    ctrl_restart <= ddata_w(1);
                 elsif daddress(15 downto 0) = MY_WORD_ADDRESS + 1 then
                    ctrl_din     <= ddata_w(23 downto 0);
                end if;
            else
                -- Desativa start/restart automaticamente após um ciclo
                --ctrl_start   <= '0';
                --ctrl_restart <= '0';
            end if;
        end if;
    end process;

end architecture;
