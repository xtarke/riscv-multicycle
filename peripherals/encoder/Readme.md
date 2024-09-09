# Encoder Frequency Measurement

Este projeto VHDL implementa uma contagem de pulsos de um encoder e calcula a frequência desses pulsos com base em um período de tempo configurável. O código permite selecionar diferentes períodos de medição e calcula a frequência em Hz (pulsos por segundo).

## Exemplo prático

Abaixo temos o exemplo de um sinal de 53 kHZ sendo injetado na placa, para que seja feita a medição de sua frequencia através do periférico implementado.

![placafrequencia2](https://github.com/user-attachments/assets/9359def6-587d-4871-8f45-2e44bb7a2341)
![placafrequencia](https://github.com/user-attachments/assets/d2db3114-3129-4139-8568-bb752e0e1ee2)

O valor medido é apresentado no display em formato hexadecimal, ou seja, CF08, que convertido a decimal, nos dá exatamente 53k, igual a frequencia do sinal injetado.

## Entidade `encoder`

A entidade `encoder` recebe os seguintes sinais de entrada e saída:

### Entradas:
- `clk`: Sinal de clock do sistema (50 MHz assumido).
- `aclr_n`: Sinal de reset ativo em baixo.
- `select_time`: Vetor de 3 bits para seleção do período de medição.
  - "000" -> 1 ms
  - "001" -> 10 ms
  - "010" -> 100 ms
  - "011" -> 1000 ms
- `encoder_pulse`: Sinal de pulso do encoder.

### Saídas:
- `frequency`: Frequência dos pulsos do encoder em Hz, é possivel medir frequencias de até 4 Mhz com esta aplicação, devido a limitação do tamanho do registrador utilizado em pulse counter.

## Arquitetura `rtl`

A arquitetura `rtl` define o seguinte comportamento:

1. **Seleção do Período de Medição:**
   - O `select_time` define o tempo de medição. O tempo é armazenado no sinal `time_period` e um multiplicador é ajustado para converter a contagem de pulsos em frequência (Hz).
   - Períodos disponíveis: 1 ms, 10 ms, 100 ms, e 1000 ms.

2. **Contagem de Pulsos:**
   - Um contador (`time_counter`) é incrementado a cada ciclo de clock até atingir o valor do `time_period`.
   - Quando o contador de tempo atinge o período definido, a frequência é calculada multiplicando a contagem de pulsos (`pulse_count`) pelo multiplicador apropriado para gerar a frequência em Hz.

3. **Reinicialização e Contagem:**
   - A cada intervalo de tempo definido, o contador de pulsos é resetado, e um novo cálculo de frequência é feito.
   - O sinal de controle `flag` garante que o contador de pulsos seja resetado corretamente no final de cada período de medição.

## Como Utilizar

- Atribua um valor de entrada ao vetor `select_time` para definir o período de medição desejado.
- Aplique o sinal do encoder no `encoder_pulse`.
- A frequência calculada será disponibilizada na saída `frequency` em pulsos por segundo.

## Sinais Importantes

- `pulse_count`: Contador de pulsos do encoder.
- `time_period`: Período de contagem selecionado.
- `time_counter`: Contador de tempo baseado no clock.
- `multiplicador`: Fator para converter a contagem de pulsos na frequência adequada.

Este código é útil para sistemas que necessitam medir a frequência de pulsos de um encoder, como em aplicações de controle de motores ou medição de velocidade de rotação.




