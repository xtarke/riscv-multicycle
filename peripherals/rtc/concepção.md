# DISPOSITIVOS LÓGICO-PROGRAMÁVEIS - IFSC - 2025.1

Implementação de um Relógio de Tempo Real (RTC) com Conversão para BCD em VHDL

Acesso rápido:

  - [Introdução](./README.md)
  - [Metodologia](./metodologia.md)
  - [Resultados](./resultados.md)
  - [Conclusão](./conclusão.md)

# Concepção

O projeto foi desenvolvido com o objetivo de implementar um Relógio de Tempo Real (RTC) funcional e preciso, utilizando a linguagem VHDL e a plataforma DE10-Lite FPGA. A escolha do VHDL foi estipulada pelo professor, com o intuito de aplicar os conceitos aprendidos na disciplina de Dispositivos Lógico-Programáveis e demonstrar a capacidade de implementar sistemas digitais temporais.

A concepção do sistema envolveu a criação de contadores binários para as unidades de tempo (segundos, minutos, horas, dias, meses e anos). Cada contador foi projetado para ser incrementado de acordo com um sinal de 1 segundo, que foi gerado por um divisor de clock. A precisão do sinal de 1 segundo foi garantida pela utilização de uma PLL, configurada no Quartus para ajustar a frequência de operação do sistema.

Além disso, foi necessário desenvolver um conversor de binário para BCD para permitir a exibição dos valores de tempo de forma legível. O sistema foi validado por meio de simulações, garantindo que a contagem fosse realizada corretamente e que os sinais de saída estivessem em conformidade com o formato BCD.

## Objetivos :

O objetivo deste projeto é aplicar os conhecimentos adquiridos na disciplina para desenvolver e implementar um Relógio de Tempo Real (RTC) em VHDL para a plataforma DE10-Lite FPGA. Através desta implementação, busca-se:

 -   Implementar contadores para medir segundos, minutos, horas, dias, meses e anos;
 -   Desenvolver um divisor de clock para gerar um sinal de 1 segundo a partir de um clock de entrada de alta frequência;
 -   Configurar uma PLL no Quartus para ajustar a frequência e garantir a precisão do sinal de 1 segundo;
 -   Converter os valores binários para BCD para permitir a exibição legível do tempo;
 -   Validar o funcionamento do sistema por meio de simulações no ModelSim;
 -   Sintetizar e implementar o sistema no hardware DE10-Lite FPGA, garantindo seu funcionamento correto.





