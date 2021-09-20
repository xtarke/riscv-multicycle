# Controlador para displays de caracteres LCD HD44780 (2021/1)

Este módulo .vhd disponibiliza uma interface para utilização de um controlador para display de caracteres LCD HD44780 Hitachi [1], permitindo utilizar displays LCD alfanuméricos 16x2.

## Objetivos
A descrição do hardware foi feita em VHDL e possui o objetivo de promover uma interface que tenha os seguintes comandos: 

1. Realizar rotina de inicialização do LCD
2. Escrever um caractere alfanumérico
3. Posicionar o cursor de escrita na primeira ou segunda linha
4. Limpar todos caracteres

De forma que o chamador destes comandos via hardware tenha uma maior abstração do funcionamento do LCD, tendo apenas que gerenciar efetivamente o que está escrito e o que deseja escrever no display.

## Projeto
A entidade projetada consiste em:
![Entidade HDL](doc/img_entity.png)

#### Esquemático de hardware
![Schematic](doc/img_schematic.png)

#### Máquinas de estado

1. Controle dos timeouts de power-up
2. Controle de temporizadores e comandos de interface com o HD44780
![Estados](doc/img_states.png)
## Resultados

Projeto atende aos objetivos 1, 2, 3 e 4, sendo possível escrever um caractere via variável/signal na posição inicial da linha 1 ou 2.

Porém, apresenta o problema em que comandos não são enviados um a um. Necessita mecanismo de sincronia para módulo enviar apenas UM comando ao LCD para cada trigger.


#### Testbenches
0. Power-up com o tempo mínimo para estabilização da tensão
![Power-up](doc/img_5ms_reset.png)
1. Máquina de estados da inicialização do LCD, contendo todos os estímulos de configuração enviados por LCD_DATA(0..7) em RS=0 (instruções).

![Inicialização](doc/img_init_states_testbench.png)


#### Montagem em hardware
![Hardware](doc/img_result.jfif)

#### Problemas encontrados:

* O comando via chave era realizado muitas vezes, pois a borda de subida de clock que é responsável pelo trigger do evento caso o bit relativo ao comando desejado esteja em 1. Resultava em, por exemplo: escritas sucessivas do mesmo caractere

#### Implementaçoes futuras
* Generalizar módulo possibilitando uso de interfaces de dados 4-bit ou 8-bit e outros tamanhos de display 
* Integração com um softcore RISC-V

## Referências

[1] SPARKFUN, Hitachi HD44780 LCD Controller Datasheet <https://www.sparkfun.com/datasheets/LCD/HD44780.pdf>
