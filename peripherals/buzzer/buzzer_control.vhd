-- Caio Neves Meira
-- IMPERIAL MARCH
-- Toca a Marcha imperial num Buzzer Ativo.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--------------------------------------
-- Definição das portas de entrada e saída do bloco
entity buzzer_control is
    port(
        clk : in std_logic;          -- Recebe o clock do processador. (50Mhz)
        reset : in std_logic;
        buzzer : out std_logic       -- Joga a informação no Buzzer
    );
end entity buzzer_control;
-------------------------------------
-- Definição do comportamento do bloco
architecture RTL of buzzer_control is

    type state_type is (
        S0, S1, S2, S3, S4, S5, S6, S7, S8,
        S9, S10, S11, S12, S13, S14, S15, S16, S17,
        S18, S19, S20, S21, S22, S23, S24, S25, S26,
        S27, S28, S29, S30, S31, S32, S33, S34, S35, S36, S37, S38, S39,
        S40, S41, S42, S43, S44, S45, S46, S47, S48, S49, S50, S51,
        S52, S53, S54, S55, S56, S57, S58, S59, S60, S61, S62, S63, S64, S65, S66,
        S67, S68, S69, S70, S71, S72, S73, S74, S75, S76, S77, S78, S79, S80, S81,
        S82, S83, S84, S85, S86, STOP
    );
    signal state : state_type := S0;

    signal counter : unsigned(31 downto 0) := (others => '0');
    signal target  : unsigned(31 downto 0);

    constant CLK_FREQ : integer := 50000000; -- 50 MHz

    -- Função auxiliar para converter ms em ciclos de clock
    function ms(n : integer) return unsigned is
    begin
        return to_unsigned(n * (CLK_FREQ / 1000), 32);
    end function;

begin

    -- Gerenciador de estado e temporização
    process(clk, reset)
    begin
        if reset = '1' then
            state   <= S0;
            counter <= (others => '0');
        elsif rising_edge(clk) then
            if counter < target then
                counter <= counter + 1;
            else
                counter <= (others => '0');
                case state is
                    when S0  => state <= S1;
                    when S1  => state <= S2;
                    when S2  => state <= S3;
                    when S3  => state <= S4;
                    when S4  => state <= S5;
                    when S5  => state <= S6;
                    when S6  => state <= S7;
                    when S7  => state <= S8;
                    when S8  => state <= S9;
                    when S9  => state <= S10;
                    when S10 => state <= S11;
                    when S11 => state <= S12;
                    when S12 => state <= S13;
                    when S13 => state <= S14;
                    when S14 => state <= S15;
                    when S15 => state <= S16;
                    when S16 => state <= S17;
                    when S17 => state <= S18;
                    when S18 => state <= S19;
                    when S19 => state <= S20;
                    when S20 => state <= S21;
                    when S21 => state <= S22;
                    when S22 => state <= S23;
                    when S23 => state <= S24;
                    when S24 => state <= S25;
                    when S25 => state <= S26;
                    when S26 => state <= S27;
                    when S27 => state <= S28;
                    when S28 => state <= S29;
                    when S29 => state <= S30;
                    when S30 => state <= S31;
                    when S31 => state <= S32;
                    when S32 => state <= S33;
                    when S33 => state <= S34;
                    when S34 => state <= S35;
                    when S35 => state <= S36;
                    when S36 => state <= S37;
                    when S37 => state <= S38;
                    when S38 => state <= S39;
                    when S39 => state <= S40;
                    when S40 => state <= S41;
                    when S41 => state <= S42;
                    when S42 => state <= S43;
                    when S43 => state <= S44;
                    when S44 => state <= S45;
                    when S45 => state <= S46;
                    when S46 => state <= S47;
                    when S47 => state <= S48;
                    when S48 => state <= S49;
                    when S49 => state <= S50;
                    when S50 => state <= S51;
                    when S51 => state <= S52;
                    when S52 => state <= S53;
                    when S53 => state <= S54;
                    when S54 => state <= S55;
                    when S55 => state <= S56;
                    when S56 => state <= S57;
                    when S57 => state <= S58;
                    when S58 => state <= S59;
                    when S59 => state <= S60;
                    when S60 => state <= S61;
                    when S61 => state <= S62;
                    when S62 => state <= S63;
                    when S63 => state <= S64;
                    when S64 => state <= S65;
                    when S65 => state <= S66;
                    when S66 => state <= S67;
                    when S67 => state <= S68;
                    when S68 => state <= S69;
                    when S69 => state <= S70;
                    when S70 => state <= S71;
                    when S71 => state <= S72;
                    when S72 => state <= S73;
                    when S73 => state <= S74;
                    when S74 => state <= S75;
                    when S75 => state <= S76;
                    when S76 => state <= S77;
                    when S77 => state <= S78;
                    when S78 => state <= S79;
                    when S79 => state <= S80;
                    when S80 => state <= S81;
                    when S81 => state <= S82;
                    when S82 => state <= S83;
                    when S83 => state <= S84;
                    when S84 => state <= S85;
                    when S85 => state <= S86;
                    when S86 => state <= STOP;
                    when STOP => state <= STOP;
                end case;
            end if;
        end if;
    end process;

    -- Define saída e tempo por estado
    process(state)
    begin
        case state is
            -- Parte 1: Tema principal
            when S0  => buzzer <= '0'; target <= ms(400);
            when S1  => buzzer <= '1'; target <= ms(133);
            when S2  => buzzer <= '0'; target <= ms(400);
            when S3  => buzzer <= '1'; target <= ms(133);
            when S4  => buzzer <= '0'; target <= ms(400); 
            when S5  => buzzer <= '1'; target <= ms(133);
            when S6  => buzzer <= '1'; target <= ms(200); --Delay

            when S7  => buzzer <= '0'; target <= ms(250);
            when S8  => buzzer <= '1'; target <= ms(83);
            when S9  => buzzer <= '0'; target <= ms(150);
            when S10  => buzzer <= '1'; target <= ms(50);
            when S11  => buzzer <= '0'; target <= ms(200); 
            when S12  => buzzer <= '1'; target <= ms(66);
            when S13  => buzzer <= '1'; target <= ms(300); --Delay

            when S14  => buzzer <= '0'; target <= ms(250);
            when S15  => buzzer <= '1'; target <= ms(83);
            when S16  => buzzer <= '0'; target <= ms(150);
            when S17  => buzzer <= '1'; target <= ms(50);
            when S18  => buzzer <= '0'; target <= ms(200); 
            when S19  => buzzer <= '1'; target <= ms(66);
            when S20  => buzzer <= '1'; target <= ms(500); --Delay

            ---- Segunda parte

            when S21  => buzzer <= '0'; target <= ms(400);
            when S22  => buzzer <= '1'; target <= ms(133);
            when S23  => buzzer <= '0'; target <= ms(400);
            when S24  => buzzer <= '1'; target <= ms(133);
            when S25  => buzzer <= '0'; target <= ms(400); 
            when S26  => buzzer <= '1'; target <= ms(133);
            when S27  => buzzer <= '1'; target <= ms(200); --Delay

            when S28  => buzzer <= '0'; target <= ms(250);
            when S29  => buzzer <= '1'; target <= ms(83);
            when S30  => buzzer <= '0'; target <= ms(150);
            when S31  => buzzer <= '1'; target <= ms(50);
            when S32  => buzzer <= '0'; target <= ms(200); 
            when S33  => buzzer <= '1'; target <= ms(66);
            when S34  => buzzer <= '1'; target <= ms(300); --Delay

            when S35  => buzzer <= '0'; target <= ms(250);
            when S36  => buzzer <= '1'; target <= ms(83);
            when S37  => buzzer <= '0'; target <= ms(150);
            when S38  => buzzer <= '1'; target <= ms(50);
            when S39  => buzzer <= '0'; target <= ms(200); 
            when S40  => buzzer <= '1'; target <= ms(66);
            when S41  => buzzer <= '1'; target <= ms(500); --Delay

            --- TERCEIRA PARTE

            when S42  => buzzer <= '0'; target <= ms(400);
            when S43  => buzzer <= '1'; target <= ms(133);
            when S44  => buzzer <= '0'; target <= ms(300);
            when S45  => buzzer <= '1'; target <= ms(100);
            when S46  => buzzer <= '0'; target <= ms(400); 
            when S47  => buzzer <= '1'; target <= ms(133);
            when S48  => buzzer <= '0'; target <= ms(300);
            when S49  => buzzer <= '1'; target <= ms(100);

            when S50  => buzzer <= '0'; target <= ms(100);
            when S51  => buzzer <= '1'; target <= ms(33);
            when S52  => buzzer <= '0'; target <= ms(100);
            when S53  => buzzer <= '1'; target <= ms(33);
            when S54  => buzzer <= '0'; target <= ms(400); 
            when S55  => buzzer <= '1'; target <= ms(133);
            when S56  => buzzer <= '1'; target <= ms(300); --delay

            when S57  => buzzer <= '0'; target <= ms(300);
            when S58  => buzzer <= '1'; target <= ms(100);
            when S59  => buzzer <= '0'; target <= ms(400);
            when S60  => buzzer <= '1'; target <= ms(133);
            when S61  => buzzer <= '0'; target <= ms(300); 
            when S62  => buzzer <= '1'; target <= ms(100);

            when S63  => buzzer <= '0'; target <= ms(100);
            when S64  => buzzer <= '1'; target <= ms(33);
            when S65  => buzzer <= '0'; target <= ms(100);
            when S66  => buzzer <= '1'; target <= ms(33);
            when S67  => buzzer <= '0'; target <= ms(400); 
            when S68  => buzzer <= '1'; target <= ms(133);
            when S69  => buzzer <= '1'; target <= ms(300); --delay

            when S70  => buzzer <= '0'; target <= ms(300);
            when S71  => buzzer <= '1'; target <= ms(100);
            when S72  => buzzer <= '0'; target <= ms(400);
            when S73  => buzzer <= '1'; target <= ms(133);
            when S74  => buzzer <= '0'; target <= ms(500); 
            when S75  => buzzer <= '1'; target <= ms(166);
            when S76  => buzzer <= '0'; target <= ms(200);
            when S77  => buzzer <= '1'; target <= ms(66); 
            when S78  => buzzer <= '0'; target <= ms(200);
            when S79  => buzzer <= '1'; target <= ms(66);
            when S80  => buzzer <= '1'; target <= ms(300); --delay

            when S81  => buzzer <= '0'; target <= ms(500);
            when S82  => buzzer <= '1'; target <= ms(166);
            when S83  => buzzer <= '0'; target <= ms(200);
            when S84  => buzzer <= '1'; target <= ms(66);
            when S85  => buzzer <= '0'; target <= ms(200); 
            when S86  => buzzer <= '1'; target <= ms(66);  


            when STOP => buzzer <= '0'; target <= ms(10000);
        end case;
    end process;

end architecture RTL;
----------------------------------

