## Controle SRAM DE2-115:

Implementou-se o controle da SRAM externa, IS61WV102416BLL-10TLI, do módulo DE2-115. A SRAM em questão possui 2M bytes de memória.

## Descrição dos pinos:

| PINS          | Descrição                           |
| ------------- |:-----------------------------------:|
| A0-A19        | Endereço de entrada                 |
| I/O0-1/O15    | Entrada e saída de dados            |
| !CE           | Saída de habilitação do chip        |
| !OE           | Output Enable Input                 |
| !WE           | Write Enable Input                  |
| !LB           | Lower-byte Control (I/O0-I/O7       |
| !UB           | Upper-byte Control (I/O8-I/O15)     |
| NC            | Sem conexão                         |
| Vdd           | Vdd power                           |
| GND           | Terra                               |

## Tabela da verdade da SRAM:

![Alt text](https://github.com/marianegri/riscv-multicycle/peripherals/sram_controle_DE2_115/tabela_verdade.jpg)

**Ciclo de Leitura**
![Alt text](https://github.com/marianegri/riscv-multicycle/peripherals/sram_controle_DE2_115/leitura.jpg)

**Ciclo de Escrita**
![Alt text](https://github.com/marianegri/riscv-multicycle/peripherals/sram_controle_DE2_115/escrita.jpg)


## Resultados:
**Modelsim Simulação**
![Alt text](https://github.com/marianegri/riscv-multicycle/peripherals/sram_controle_DE2_115/modelsim.png)

* Simulação com funcionamento adequado.
* Ao colocar no kit de desenvolvimento da altera percebe-se que a leitura não ocorre como o esperado. Possíveis causas:
  * Sincronismo.
  * Tempos de acionamento dos pinos diferente do esperado.


## Bibliografia
[DATASHEET](https://br.mouser.com/datasheet/2/198/61WV102416ALL-258682.pdf)

