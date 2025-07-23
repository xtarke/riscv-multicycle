# DISPOSITIVOS LÓGICO-PROGRAMÁVEIS - IFSC - 2025.1

Implementação de um Relógio de Tempo Real (RTC) com Conversão para BCD em VHDL

Acesso rápido:  
  - [Introdução](./README.md)
  - [Concepção](./concepção.md)
  - [Metodologia](./metodologia.md)
  - [Resultados](./resultados.md)

# Conclusão

O projeto foi bem-sucedido na implementação de um Relógio de Tempo Real (RTC) em VHDL, utilizando a plataforma DE10-Lite FPGA. Através das simulações realizadas no ModelSim e testes no hardware real, foi possível validar a precisão do sistema de contagem de tempo, que inclui segundos, minutos, horas, dias, meses e anos. A conversão para BCD foi implementada de forma eficiente e corretamente exibida nos displays de 7 segmentos.

A implementação do divisor de clock e a configuração da PLL no Quartus garantiram a geração precisa do sinal de 1 segundo, essencial para a operação do RTC. A utilização do VHDL permitiu uma descrição precisa do sistema e a sua validação tanto em simulação quanto no hardware real, confirmando que o projeto atende aos requisitos de funcionalidade.

Este projeto serviu como uma excelente aplicação dos conceitos da disciplina de Dispositivos Lógico-Programáveis e forneceu uma base sólida para o desenvolvimento de sistemas temporais mais complexos, como cronômetros, temporizadores e sistemas de alarme, em FPGAs.



