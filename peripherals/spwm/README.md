# SPWM

Implementação de um componente VHDL gerador de PWM senoidal a partir da comparação entre as ondas referência (senoide) e portadora (triangular).

## Descrição dos pinos


- `clock`: sinal de entrada de clock. Os divisores de clock para geração das ondas funcionam na borda de subida do clock.  

- `reset`: sinal de reset do periférico, deve ser conectado ao barramento do `reset` do _core_.  

- `sel_modulation`: Seleciona qual modulação será apresentada na saída.

- `sine_spwm1`: Saída 1 do pwm senoidal gerado pelo hardware.

- `sine_spwm2`: Saída 2 do pwm senoidal gerado pelo hardware.

- `sine_spwm3`: Saída 3 do pwm senoidal gerado pelo hardware.

- `sine_spwm4`: Saída 4 do pwm senoidal gerado pelo hardware.


## Funcionamento
Faz um divisor do clock de entrada para os processos da referência (senoide) e portadora (triangular). Esses clocks são usados para dos valores da portadora e da moduladora.

Os valores da portadora são atualizados a partir de uma tabela de valores da senoide gerada pelo script em python.

O valor da moduladora segue a lógica de uma onda triangular de acordo com o valor de contagem máxima e uma variável de fator de multiplicação para que possa ser implementada modulação de amplitude.

É feita a comparaçao entre portadora e moduladora e o sinal pwm é gerado nas saídas sine_spwm. É possível selecionar qual modulação será escolhida, Bipolar ou Unipolar.

Observe abaixo a lógica implementada e o exemplo simulado via PSIM.

## Modulação Bipolar

- sine_spwm1 = 1  quando Vseno > Vtriangular
- sine_spwm1 = 0  quando Vseno < Vtriangular

<p align="center">
<img src="https://github.com/xtarke/riscv-multicycle/blob/master/peripherals/spwm/spwm_example.png" width="436" height="326">

Em uma aplicação para inversores monofásicos utilizamos 4 chaves, precisamos apenas de 1 sinal comparado com a tabela e seu complementar. A disposição das chaves ficam exemplificados abaixo:


- Chave 1 = Chave 3 = sine_spwm1 = sine_spwm3
- Chave 2 = Chave 4 = sine_spwm2 = sine_spwm4

## Modulação Unipolar

O modelo de chaveamento segue da mesma forma que a modulação bipolar, porém agora com um sinal defasado.

- sine_spwm1 = 1  quando Vseno > Vtriangular
- sine_spwm1 = 0  quando Vseno < Vtriangular
- sine_spwm2 = 1  quando Vseno_offset > Vtriangular
- sine_spwm2 = 0  quando Vseno_offset < Vtriangular

<p align="center">
<img src="https://github.com/RamonSerafim/riscv-multicycle/blob/master/peripherals/spwm/spwm_example_unipolar.png" width="436" height="326">



Em uma aplicação para inversores monofásicos utilizamos 4 chaves, precisamos de 2 sinais comparado com a tabela e seus complementares. A primeira tabela disponibilizando 1 sinal e seu complementar e a outra tabela sendo defasada 180º da primeira, tendo como resposta 1 sinal e seu complementar  A disposição das chaves ficam exemplificados abaixo:




- Chave 1 = sine_spwm1 = a partir de table_sine
- Chave 2 = sine_spwm2 = a partir de table_sine_offset
- Chave 3 = sine_spwm3 = complementar de sine_spwm1 
- Chave 4 = sine_spwm4 = complementar de sine_spwm2

## Simulação

Os valores a seguir foram gerados no Questa utilizando os arquivos de testbench e também o exemplo de software main_spwm.c encontrado nesse repositório, no caminho software/spwm/.

Valores padrão: frequência do seno 50Hz, frequência da portadora 1kHz, razão de amplitude 100%.

Observe os valores de entrada e a saída:

![Entradas e Saída](https://github.com/xtarke/riscv-multicycle/blob/master/peripherals/spwm/spwm_output.png)

Foi aplicado um zoom para mostrar os valores das ondas de referência e portadora:

![Referência e Portadora](https://github.com/xtarke/riscv-multicycle/blob/master/peripherals/spwm/spwm_internal_signals.png)

## Sugestões
- Testar lógica de modulação de amplitude
- Adequar o componente para N saídas e com a lógica de chaveamento para - aplicação. Exemplos: conversor B6, inversor monofásico
- Gerar a tabela de valores da senoide em tempo de compilação
