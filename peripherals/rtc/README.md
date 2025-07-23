# RTC em VHDL - Implementação de um Relógio de Tempo Real com Conversão para BCD

## DISPOSITIVOS LÓGICO-PROGRAMÁVEIS - IFSC - 2025.1

Instituto Federal de Educação, Ciência e Tecnologia de Santa Catarina - Campus Florianópolis

Departamento Acadêmico de Eletrônica

Licenciatura em Engenharia Eletrônica

__*Matéria:*__
* Dispositivos Lógico-Programáveis

__*Professor:*__

* Renan Augusto Starke

__*Aluno:*__

* Thais Silva Lisatchok


Acesso rápido:

  - [Concepção](./concepção.md)
  - [Metodologia](./metodologia.md)
  - [Resultados](./resultados.md)
  - [Conclusão](./conclusão.md)

## Introdução 

Este projeto tem como intuito a implementação de um Relógio de Tempo Real (RTC) em VHDL, utilizando a plataforma DE10-Lite FPGA. O projeto foi desenvolvido para demonstrar a compreensão dos conceitos abordados na disciplina de Dispositivos Lógico-Programáveis, focando na implementação de sistemas temporais digitais. O RTC foi projetado para medir e exibir o tempo com precisão, através da contagem de segundos, minutos, horas, dias, meses e anos, com a conversão de valores para BCD (Binary Coded Decimal).

A implementação do RTC foi realizada utilizando VHDL, uma linguagem de descrição de hardware que permite a modelagem de sistemas digitais de forma eficiente. O sistema foi validado por meio de simulações no ModelSim e implementado na plataforma DE10-Lite FPGA após a síntese no Quartus, utilizando uma PLL (Phase-Locked Loop) e um divisor de clock para gerar o sinal de 1 segundo necessário para o RTC.