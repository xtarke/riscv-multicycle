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

* IMAGEM

#### Esquemático de hardware

* IMAGEM

## Resultados

#### Testbench

#### Validação (In-system sources and probes)

#### Montagem em hardware

#### Implementaçoes futuras
* Generalizar módulo possibilitando uso de interfaces de dados 4-bit ou 8-bit e outros tamanhos de display 
* Integração com um softcore RISC-V

## Referências

[1] SPARKFUN, Hitachi HD44780 LCD Controller Datasheet <https://www.sparkfun.com/datasheets/LCD/HD44780.pdf>
