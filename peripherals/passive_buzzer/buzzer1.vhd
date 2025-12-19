--------------------------------------------------------------------------------
-- Arquivo: buzzer1.vhd
-- Author: Sarah Bararua
-- Descrição: Gerador de música com seletor (Imperial March & Jingle Bells)
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity buzzer is
    generic ( CLK_FREQ : integer := 50_000_000 );
    port (
        clk        : in  std_logic;
        sw_imperial: in  std_logic; -- SW0
        sw_jingle  : in  std_logic; -- SW1
        wave_out   : out std_logic --- saída do buzzer
    );
end entity buzzer;

architecture rtl of buzzer is

--------- Frequências das Notas-------------------------

    constant NOTE_C4 : integer := 261;
    constant NOTE_D4 : integer := 294;
    constant NOTE_E4 : integer := 330;
    constant NOTE_F4 : integer := 349;
    constant NOTE_G4 : integer := 392;
    constant NOTE_A4 : integer := 440;
    constant NOTE_Bb4: integer := 466;
    constant NOTE_Eb4: integer := 311;
    
-------- Converte a frequência da nota no número de ciclos de clock ------

    -- Calculo dos Toggles (Clock / Freq / 2)
    function calc_tog(freq : integer) return integer is
    begin
        return (CLK_FREQ / freq) / 2;
    end function;

-------- Estrutura da Nota----------------------------

    type t_note is record
        half_period : integer;  --- frequencia da nota
        duration_ms : integer; ---- quanto tempo dura
    end record;

-------- Tamanho Máximo das Músicas -------------------
    constant MAX_LEN : integer := 11; 
    type t_song is array (0 to MAX_LEN-1) of t_note;

-------- 1. MARCHA IMPERIAL (9 notas)
    constant SONG_IMP : t_song := (
        (calc_tog(NOTE_G4),  5),
	    (calc_tog(NOTE_G4),  5),
	    (calc_tog(NOTE_G4),  5), 
        (calc_tog(NOTE_Eb4), 3),
	    (calc_tog(NOTE_Bb4), 1),
	    (calc_tog(NOTE_G4),  5), 
        (calc_tog(NOTE_Eb4), 3),
	    (calc_tog(NOTE_Bb4), 1),
	    (calc_tog(NOTE_G4), 10),
        (0,0), (0,0) -- Padding para reiniciar musica
         );

-------- 2. JINGLE BELLS (11 notas)
    constant SONG_JINGLE : t_song := (
        (calc_tog(NOTE_E4), 3),
	    (calc_tog(NOTE_E4), 3),
	    (calc_tog(NOTE_E4), 6),
        (calc_tog(NOTE_E4), 3),
	    (calc_tog(NOTE_E4), 3),
	    (calc_tog(NOTE_E4), 6),
        (calc_tog(NOTE_E4), 3),
	    (calc_tog(NOTE_G4), 3),
	    (calc_tog(NOTE_C4), 3), 
        (calc_tog(NOTE_D4), 3),
	    (calc_tog(NOTE_E4), 9) 
         );

-------- Sinais de Controle -------------------

    signal note_idx : integer range 0 to MAX_LEN-1 := 0;  --- nota atual
    signal cnt_tone : integer := 0;		 --- contador para gerar frequancia
    signal cnt_time : integer := 0;		 --- duracao da nota em ms
    signal ms_tick  : integer := 0;		 --- divisor declock para ms
    signal wave_reg : std_logic := '0';		 --- registrador da onda de saida
    
    -- Seleção da nota atual
    signal current_note : t_note; 		---- nota selecionada pelo multiplexador 

begin

-------- Multiplexador: Escolhe qual música tocar baseado na chave ------

    process(sw_imperial, sw_jingle, note_idx)
    begin
        if sw_imperial = '1' then
            current_note <= SONG_IMP(note_idx);  --- tocar marcha imperial
        elsif sw_jingle = '1' then
            current_note <= SONG_JINGLE(note_idx);  ---- tocar jingle bells
        else
            -- Se nenhuma chave ligada, nota vazia
            current_note <= (half_period => 0, duration_ms => 0);
        end if;
    end process;

-------------- Processo Principal--------------

    process(clk)
    begin
        if rising_edge(clk) then
            --- Reset se nenhuma chave estiver ligada---
            if sw_imperial = '0' and sw_jingle = '0' then
                note_idx <= 0;	--- voltar a primeira nota
                cnt_time <= 0;	--- zerar temporizador
                cnt_tone <= 0;	--- zera gerador de freq
                wave_reg <= '0'; -- buzzer/led desligado
            else
                ---  Gerador de Tom (Se a nota for válida)
                if current_note.half_period > 0 then
                    if cnt_tone >= current_note.half_period then
                        cnt_tone <= 0;
                        wave_reg <= not wave_reg;
                    else
                        cnt_tone <= cnt_tone + 1;
                    end if;
                else
                    wave_reg <= '0'; -- Silêncio se for fim da música
                end if;

                ---  Controle de Tempo (ms)
                if ms_tick >= (CLK_FREQ / 1000) - 1 then
                    ms_tick <= 0;
                    
                    -- Se a duração for 0, é fim da música ou padding
                    if current_note.duration_ms > 0 then
                        if cnt_time >= current_note.duration_ms then
                            cnt_time <= 0;
                            -- Próxima nota
                            if note_idx < MAX_LEN - 1 then
                                note_idx <= note_idx + 1;
                            else
                                note_idx <= 0; -- Loop reinicia a musica
                            end if;
                            cnt_tone <= 0; -- Reset de fase /zera o gerador de onda
                        else
                            cnt_time <= cnt_time + 1;
                        end if;
                    else
                        -- Se chegou numa nota vazia, volta pro começo
                        note_idx <= 0;
                    end if;
                else
                    ms_tick <= ms_tick + 1;
                end if;
            end if;
        end if;
    end process;
 ------- Saída final da forma de onda para o buzzer------
    wave_out <= wave_reg;

end architecture rtl;