# SPWM

Implementação de um componente VHDL gerador de PWM senoidal a partir da comparação entre as ondas referência (senoide) e portadora (triangular).

## Descrição dos pinos


- `clock`: sinal de entrada de clock. Os divisores de clock para geração das ondas funcionam na borda de subida do clock.  

- `reset`: sinal de reset do periférico, deve ser conectado ao barramento do `reset` do _core_.  

- `sine_spwm`: Saída do pwm senoidal gerado pelo hardware


## Funcionamento
Faz um divisor do clock de entrada para os processos da referência (senoide) e portadora (triangular). Esses clocks são usados para dos valores da portadora e da moduladora.

Os valores da portadora são atualizados a partir de uma tabela de valores da senoide gerada pelo script em python.

O valor da moduladora segue a lógica de uma onda triangular de acordo com o valor de contagem máxima e uma variável de fator de multiplicação para que possa ser implementada modulação de amplitude.

É feita a comparaçao entre portadora e moduladora e o sinal pwm é gerado na saída sine_spwm. Observe abaixo a lógica implementada e o exemplo simulado via PSIM.

- sine_spwm = 1  quando Vseno > Vtriangular
- sine_spwm = 0  quando Vseno < Vtriangular

<p align="center">
<img src="https://github.com/xtarke/riscv-multicycle/blob/master/peripherals/spwm/spwm_example.png" width="436" height="326">

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