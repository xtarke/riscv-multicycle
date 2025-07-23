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

![ModelSim](https://github.com/thaislisatchok/PI3-IFSC-2024-1/blob/main/Thais_Guido/imagens.md/protoboard1.jpeg)

![ModelSim](https://github.com/thaislisatchok/PI3-IFSC-2024-1/blob/main/Thais_Guido/imagens.md/protoboard1.jpeg)


**2. Funcionamento do Sistema**

Após a simulação, o código foi carregado no DE10-Lite FPGA e testado fisicamente. O RTC começou a contar os segundos, minutos e horas de forma precisa, e os valores foram exibidos corretamente nos displays de 7 segmentos.

Abaixo, segue um gif que demonstra o funcionamento do sistema, mostrando a contagem de tempo e a exibição dos valores no hardware real. O RTC começa com o valor de 00:00:00 e vai contando até que o limite de 59 segundos, 59 minutos e 23 horas seja alcançado, reiniciando a contagem.

![Sintese](https://github.com/thaislisatchok/PI3-IFSC-2024-1/blob/main/Thais_Guido/imagens.md/protoboard1.jpeg)

![Gif](https://github.com/thaislisatchok/PI3-IFSC-2024-1/blob/main/Thais_Guido/imagens.md/protoboard1.jpeg)


**3. Diagrama de Blocos**

O diagrama de blocos a seguir mostra a interação entre os principais componentes do sistema, incluindo o RTC, divisor de clock, e os conversores binário para BCD. O diagrama ajuda a entender como o sinal de clock é processado, como os contadores são incrementados e como os valores são convertidos para BCD para exibição.

![Diagrama_Blocos](https://github.com/thaislisatchok/PI3-IFSC-2024-1/blob/main/Thais_Guido/imagens.md/protoboard1.jpeg)


