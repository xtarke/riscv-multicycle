# DISPOSITIVOS LÓGICO-PROGRAMÁVEIS - IFSC - 2025.1

Implementação de um Relógio de Tempo Real (RTC) com Conversão para BCD em VHDL

Acesso rápido:

  - [Introdução](./README.md)
  - [Concepção](./concepção.md)
  - [Resultados](./resultados.md)
  - [Conclusão](./conclusão.md)

# Metodologia

A metodologia foi dividida em várias etapas para garantir a implementação eficiente e funcional do RTC:

**1. Desenvolvimento do Código VHDL para o RTC**

A primeira etapa consistiu no desenvolvimento do código VHDL para a implementação do Relógio de Tempo Real (RTC), focando na criação dos contadores para medir segundos, minutos, horas, dias, meses e anos. Inicialmente, os contadores foram projetados de forma simples para contar até seus respectivos limites (59 para segundos, 59 para minutos, 23 para horas, 31 para dias, 12 para meses e 99 para anos).

**2. Implementação do Conversor Binário para BCD**

Foi criado o conversor bin_to_bcd.vhd que realiza a conversão dos valores binários dos contadores para o formato BCD. O método utilizado foi o shift-and-add-3, um algoritmo eficiente para conversão binária para BCD. O código para o conversor foi estruturado para processar até 16 bits, adequado para os valores de tempo (por exemplo, horas e anos).

**3. Testbench e Simulação no ModelSim**

Após o desenvolvimento do código do RTC, foi criada a simulação utilizando o testbench.vhd. O testbench foi projetado para simular a contagem de tempo e verificar se a conversão para BCD estava funcionando corretamente.

O código do testbench é responsável por gerar o sinal de clock e o sinal de reset, e monitorar as saídas do RTC (segundos, minutos, horas, etc.). Além disso, o testbench também exibe os valores das variáveis de tempo em um formato legível para garantir que a contagem e a conversão estão corretas.

A simulação foi realizada utilizando o ModelSim, onde foi gerado o arquivo tb.do, que contém os comandos para compilar os arquivos VHDL e executar a simulação. O comando vsim foi utilizado para iniciar a simulação, e a forma de onda foi visualizada utilizando o comando view wave.

A seguir é possível acessar o código para simulação: 

[**Clique aqui**](./codigo_modelsim.md/ProjetoFinal_RTC_ModelSim)

**4. Implementação do Código para o DE10-Lite**

Após a validação no ModelSim, a próxima etapa foi a implementação do código no **DE10-Lite FPGA**. Para isso, foi necessário criar a estrutura básica do código VHDL para configurar o FPGA, incluindo os módulos necessários para os displays de 7 segmentos e os sinais de controle de entrada, buffers e saídas.

Essa etapa envolveu a conexão do RTC com os displays de 7 segmentos, que exibem os valores de tempo (segundos, minutos e horas). Além disso, foram atribuídos os switches para controlar o reset e o clock, permitindo simular o comportamento do sistema em tempo real.

**5. Configuração da PLL no Quartus**

Com o código do DE10-Lite preparado, foi configurada a PLL (Phase-Locked Loop) no software Quartus para ajustar a frequência do clock. A frequência de entrada foi configurada para 10 MHz, e a saída da PLL foi ajustada para 0,0032786 MHz. Esse ajuste foi necessário para garantir que o divisor de clock gerasse um sinal de 1 segundo de maneira precisa.

A configuração da PLL foi feita dentro do Quartus, utilizando o IP Catalog para criar um módulo de PLL com as especificações de frequência desejadas. Essa configuração assegura que o sinal de 1 segundo seja gerado de forma precisa, garantindo a sincronização correta do RTC.

**6. Implementação do Divisor de Clock**

A última etapa do desenvolvimento envolveu a implementação do divisor de clock em VHDL. O divisor de clock foi responsável por dividir o sinal de alta frequência da PLL e gerar um sinal de 1 segundo, que é usado para controlar os contadores do RTC.

O divisor de clock foi configurado para operar com um contador interno, que, ao atingir um valor pré-definido (16393 ciclos), gera um sinal de 1 segundo. Esse sinal foi então utilizado para incrementar os contadores do RTC, mantendo a contagem precisa.

A implementação foi feita dentro do Quartus e testada para garantir que o sinal de 1 segundo fosse gerado corretamente, permitindo que os contadores fossem atualizados a cada ciclo.

**7. Síntese e Implementação Final**

Após a implementação e verificação dos módulos, o próximo passo foi sintetizar o código, permitindo validar o funcionamento do RTC no hardware real. A partir de então, o RTC foi testado no DE10-Lite, e os valores de tempo (segundos, minutos, horas) foram exibidos nos displays de 7 segmentos, confirmando que o sistema estava funcionando corretamente, tanto no software (ModelSim) quanto no hardware real.

Abaixo é possível acessar o código completo de síntese: 

[**Clique aqui**](./codigo_quartus.md/ProjetoFinal_sintese_Quartus)
