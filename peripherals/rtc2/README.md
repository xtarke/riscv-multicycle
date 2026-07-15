# Controlador do RTC

O RTC (Real Time Clock) é um periférico desenvolvido para o projeto riscv-multicycle, permitindo ao processador RISC-V acessar e controlar um relógio de tempo real através de registradores mapeados em memória (Memory Mapped I/O).

# Pinagem do periférico

Entradas:
- `clk`      : _Clock_ do periférico. Os registradores são atualizados na borda de subida.
- `rst`      : _Reset_ do periférico. Opera em lógica regular (`1` ativa o reset).
- `d_rd`     : Habilita a leitura dos registradores do RTC. Opera em lógica regular (`1` ativa a leitura).
- `d_we`     : Habilita a escrita nos registradores do RTC. Opera em lógica regular (`1` ativa a escrita).
- `daddress` : Endereço de 32 bits apresentado pelo núcleo RISC-V no barramento de dados.
- `dcsel`    : Seletor da região de endereçamento. O valor `"10"` corresponde à região de periféricos.
- `ddata_w`  : Dado de 32 bits enviado pelo núcleo RISC-V para escrita no periférico.
- `dmask`    : Máscara de habilitação dos bytes da palavra de 32 bits.

Saídas:
- `ddata_r` : Dado de 32 bits devolvido ao núcleo RISC-V durante uma operação de leitura.
- `sec_o`   : Valor atual dos segundos, representado em 6 bits.
- `min_o`   : Valor atual dos minutos, representado em 6 bits.
- `hour_o`  : Valor atual das horas, representado em 5 bits.


# Funcionamento do periférico
Após o reset, os registradores de segundos, minutos e horas são inicializados em zero. O registrador de controle é inicializado com valor 1, habilitando automaticamente a contagem do tempo.
Enquanto o registrador de controle (ctrl_reg) permanecer em nível lógico alto, o registrador tick_counter incrementa a cada ciclo de clock.

Quando tick_counter atinge CLOCK_HZ-1, ocorre:

• incremento dos segundos;

• atualização dos minutos quando segundos atingem 59;

• atualização das horas quando minutos atingem 59;



# Simulação da inicialização do RTC
Para simulação incial do sistema foi usado o testbench:[`peripherals/rtc2/tb_rtc2.vhd`](../../peripherals/rtc2/tb_rtc2.vhd)

<img width="1842" height="742" alt="image" src="https://github.com/user-attachments/assets/1f90442d-4de8-4368-9ebf-75ced055bc61" />

# Integração do _hardware_ ao núcleo RISCV

De início foi adicionado o endereço do periférico ao núcleo RISCV. Para isso, foram modificados e escritos os seguintes arquivos: 

1. [`memory/iodatabusmux.vhd`](../../memory/iodatabusmux.vhd)
```VHDL
entity iodatabusmux is
    port(
        [...]
        ddata_r_rtc : in std_logic_vector(31 downto 0);
        -- Mux 
        ddata_r_periph   : out std_logic_vector(31 downto 0) --! Connect to data bus mux
    );
end entity iodatabusmux;

architecture RTL of iodatabusmux is

begin
    -- Word address, ignoring least significant 4 bytes
    with daddress(19 downto 4) select ddata_r_periph <=
        [...]
        ddata_r_rtc when x"0019", -- <- Seleciona o endereço do periférico quando o valor for igual a x"0019".
        -- Add new io peripherals here
        (others => '0') when others;
end architecture RTL;
```

2. [`software/_core/hardware.h`](../../software/_core/hardware.h)
```C
#ifndef __HARDWARE_H
#define __HARDWARE_H

[...]
#define RTC_BASE_ADDRESS 		            (*(_IO32 *) (PERIPH_BASE + 25*16*4)) /* <-  Adicionado o endereço base do RTC a partir do endereço base para periféricos. */

#endif //HARDWARE_H
```

3. [`software/rtc2/rtc.h`](../../software/rtc2/rtc.h)

O arquivo rtc.h define os registradores do periférico RTC a partir do endereço base declarado em hardware.h, onde cada macro representa um registrador de 32 bits do periférico.
O endereço de cada registrador é obtido somando um deslocamento ao endereço base RTC_BASE_ADDRESS. Como o endereço base é definido como um registrador de 32 bits, cada incremento representa o avanço de uma palavra de 32 bits, que equivale a 4 bytes.

```C
#ifndef RTC_H
#define RTC_H

#include <stdint.h>
#include "../_core/hardware.h"

#define RTC_SEC     *(&RTC_BASE_ADDRESS + 0)
#define RTC_MIN     *(&RTC_BASE_ADDRESS + 1)
#define RTC_HOUR    *(&RTC_BASE_ADDRESS + 2)
#define RTC_DAY     *(&RTC_BASE_ADDRESS + 3)
#define RTC_MONTH   *(&RTC_BASE_ADDRESS + 4)
#define RTC_YEAR    *(&RTC_BASE_ADDRESS + 5)
#define RTC_CTRL    *(&RTC_BASE_ADDRESS + 6)

uint32_t rtc_read_sec(void);
uint32_t rtc_read_min(void);
uint32_t rtc_read_hour(void);

void rtc_write_sec(uint32_t value);
void rtc_write_min(uint32_t value);
void rtc_write_hour(uint32_t value);

void rtc_enable(void);
void rtc_disable(void);

#endif
```
As funções rtc_read_sec, rtc_read_min e rtc_read_hour realizam a leitura dos registradores de segundos, minutos e horas, rtc_write_sec, rtc_write_min e rtc_write_hour permitem configurar os valores iniciais do relógio e pro fim rtc_enable e rtc_disable controlam a contagem do RTC.


4. [`software/rtc2/rtc.c`](../../software/rtc2/rtc.c)

As funções de leitura retornam diretamente o conteúdo dos registradores mapeados em memória. As funções de escrita atribuem um novo valor aos registradores correspondentes. 
Ao executar rtc_enable, o valor 1 é escrito no registrador de controle, habilitando a contagem.
 
```C
#include "rtc.h"

uint32_t rtc_read_sec(void)
{
    return RTC_SEC;
}

uint32_t rtc_read_min(void)
{
    return RTC_MIN;
}

uint32_t rtc_read_hour(void)
{
    return RTC_HOUR;
}

void rtc_write_sec(uint32_t value)
{
    RTC_SEC = value;
}

void rtc_write_min(uint32_t value)
{
    RTC_MIN = value;
}

void rtc_write_hour(uint32_t value)
{
    RTC_HOUR = value;
}

void rtc_enable(void)
{
    RTC_CTRL = 1;
}

void rtc_disable(void)
{
    RTC_CTRL = 0;
}
```



## Exemplo

Ao fim do desenvolvimento das funções,foi feito um exemplo no arquivo, [`software/rtc2/main_rtc.c`](../../software/rtc2/main_rtc.c)

Os registradores de horas, minutos e segundos são configurados com os valores 0. Em seguida, a contagem do RTC é habilitada por meio da função rtc_enable.

Durante a execução, o programa permanece em um laço infinito, realizando continuamente a leitura dos registradores de segundos, minutos e horas através da função rtc_read_sec.

A função `two_digits` separa cada valor em dezena e unidade. A dezena é posicionada nos quatro bits mais significativos do byte, enquanto a unidade permanece nos quatro bits menos significativos. Os valores convertidos são agrupados em uma palavra de 32 bits e escritos no registrador `SEGMENTS`, que pertence ao periférico `led_displays`. Por esse motivo foi incluso o arquivo gpio.h.

```C
#include <stdint.h>
#include "rtc/rtc.h"
#include "gpio/gpio.h"

static uint32_t two_digits(uint32_t value)
{
    uint32_t unit = value % 10;
    uint32_t ten  = value / 10;

    return (ten << 4) | unit;
}

int main(void)
{
    rtc_write_hour(0);
    rtc_write_min(0);
    rtc_write_sec(0);
    rtc_enable();

    while (1)
    {
        uint32_t sec  = rtc_read_sec();
        uint32_t min  = rtc_read_min();
        uint32_t hour = rtc_read_hour();

        SEGMENTS =
            (two_digits(hour) << 16) |
            (two_digits(min)  << 8)  |
            (two_digits(sec));

    }

    return 0;
}
```


## Compilação do exemplo

A compilação é feita com o auxílio do arquivo [`software/Makefile`](../../software/Makefile).
É necessário instalar o compilador `riscv-none-embed-gcc`, e o caminho do compilador deve estar configurado corretamente no `Makefile`, por exemplo:
```Makefile
RISCV_TOOLS_PREFIX = ../compiler/gcc/bin/riscv-none-elf-
```

O nome da arquivo que será executado também é definido no Makefile:

```Makefile
MAIN = main_rtc
```
A compilação foi feita pelo terminal MSYS2, onde foi acessado a pasta [`software/rtc2`](../../software/rtc2).
Executando os comandos "make clean" para limpar algum arquivo antigo e "make" para gerar o novo arquivo .hex 

```text
quartus_main_rtc.hex
```

# Simulação do _testbench_


O _testbench_ foi implementado no arquivo [`peripherals/rtc2/testbench2.vhd`](../../peripherals/rtc2/testbench2.vhd), ele já possui integração ao núcleo RISCV e exibe nas suas últimas linhas os sinais de saída para o _display_:

<img width="1872" height="739" alt="image" src="https://github.com/user-attachments/assets/ca1acbbf-5ca4-4196-9586-073072764254" />


# Síntese na FPGA Altera MAX10 DE10-Lite

O arquivo principal para síntese é o [`sint/de10_lite/de0_lite.vhd`](sint/de10_lite/de0_lite.vhd)

Ao final, após a síntese e gravação do arquivo .hex na memória interna utilizada para o núcleo RISCV, é possível observar o funcionamento do RTC. A fim de teste, foram setadas as horas e minutos nos displays.

<img width="25%" height="25%" src="PLD_rtcGIF.gif">

# Bibliografia

[1] [_Datasheet_ da placa de desenvolvimento Altera DE10-Lite](https://www.intel.com/content/dam/www/programmable/us/en/portal/dsn/42/doc-us-dsnbk-42-2912030810549-de10-lite-user-manual.pdf)

