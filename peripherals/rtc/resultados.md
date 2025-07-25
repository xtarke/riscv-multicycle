# DISPOSITIVOS LÓGICO-PROGRAMÁVEIS - IFSC - 2025.1

Implementação de um Relógio de Tempo Real (RTC) com Conversão para BCD em VHDL

Acesso rápido:

  - [Introdução](./README.md)
  - [Concepção](./concepção.md)
  - [Metodologia](./metodologia.md)
  - [Conclusão](./conclusão.md)

# Resultados

A seguir, são feitas as análises dos resultados obtidos em diferentes etapas do projeto:

**1. Simualação no ModelSim**

A simulação no ModelSim foi realizada para verificar se o RTC estava funcionando corretamente e se a conversão para BCD estava sendo feita de forma precisa. Durante a simulação, foi possível observar a contagem dos segundos, minutos e horas, além de monitorar o comportamento dos conversores binário para BCD.

Abaixo, segue a forma de onda gerada no ModelSim, mostrando os sinais de segundos, minutos e horas, e sua conversão para BCD. As saídas do RTC (segundos, minutos, horas) foram observadas de forma contínua e precisa.

![ModelSim](https://github.com/thaislisatchok/riscv-multicycle/blob/master/peripherals/rtc/imagens.md/modelsim1.png)

![ModelSim](https://github.com/thaislisatchok/riscv-multicycle/blob/master/peripherals/rtc/imagens.md/modelsim2.png)


**2. Funcionamento do Sistema**

Após a simulação, o código foi carregado no DE10-Lite FPGA e testado fisicamente. O RTC começou a contar os segundos, minutos e horas de forma precisa, e os valores foram exibidos corretamente nos displays de 7 segmentos.

Abaixo, segue um gif que demonstra o funcionamento do sistema, mostrando a contagem de tempo e a exibição dos valores no hardware real. O RTC começa com o valor de 00:00:00 e vai contando até que o limite de 59 segundos, 59 minutos e 23 horas seja alcançado, reiniciando a contagem.

![Sintese](https://github.com/thaislisatchok/riscv-multicycle/blob/master/peripherals/rtc/imagens.md/sintese.jpg)

![Gif](https://github.com/thaislisatchok/riscv-multicycle/blob/master/peripherals/rtc/imagens.md/Gif.gif)


**3. Diagrama de Blocos**

O diagrama de blocos a seguir ilustra a arquitetura funcional do sistema de Relógio de Tempo Real (RTC) desenvolvido em VHDL. Nele, é possível observar a interação entre os principais módulos que compõem o projeto:

- **Módulo `rtc` (work.rtc)**: representa a unidade principal do sistema, responsável por coordenar o funcionamento do RTC. Ele gerencia os contadores de tempo (segundos, minutos, horas, dia, mês e ano) e realiza o controle global dos sinais.

- **Divisor de clock (`divisor_clock`)**: recebe o sinal de clock de alta frequência (32.768 Hz) e o divide para gerar um pulso de 1 Hz. Esse sinal reduzido é utilizado para a atualização dos contadores de tempo de forma precisa, uma vez por segundo.

- **Conversores de Binário para BCD (`bin_to_bcd`)**: cada campo de tempo (segundos, minutos, horas, dia, mês e ano) é convertido de binário para o formato BCD (Binary-Coded Decimal), facilitando a exibição direta dos valores em displays de 7 segmentos ou outros dispositivos de visualização digital.

- **Sinais auxiliares de controle (`num_signal`)**: indicam quando o valor binário deve ser convertido para BCD, sincronizando a conversão com a atualização dos contadores.

- **Saídas segmentadas (`seg0` a `seg5`)**: representam as divisões de dígitos em BCD para exibição dos diferentes campos de tempo.

Este diagrama permite visualizar com clareza o fluxo de dados e controle no sistema: desde a entrada do clock, passando pela divisão de frequência, incremento dos contadores binários, até a conversão final em BCD. Com isso, compreende-se a lógica sequencial envolvida na atualização e exibição das informações temporais no relógio.


![Diagrama_Blocos](https://github.com/thaislisatchok/riscv-multicycle/blob/master/peripherals/rtc/imagens.md/diagrama_blocos.png)


