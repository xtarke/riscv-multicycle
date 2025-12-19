# Protocolo OneShot125
**Aluna:** Diana Macedo Rodrigues

**Máteria:** Dispositivos Lógico -Programáveis

# Visão Geral

Este projeto implementa a verificação e o controle do protocolo OneShot125 utilizando VHDL. O sistema é capaz de gerar sinais PWM não tradicionais, com larguras de pulso variando entre 125µs (mínimo) e 250µs (máximo). O controle da velocidade pode ser realizado de forma dinâmica via software (Probe) ou através de valores pré-definidos acionados por chaves físicas, permitindo testar a resposta do protocolo em diferentes cenários de aceleração.

# Funcionamento do projeto

O sistema opera utilizando o clock mestre de 50 MHz da placa DE10-Lite. O funcionamento baseia-se na modulação de largura de pulso e multiplexação de fonte de dados:

Protocolo OneShot125: Diferente do PWM padrão, o ciclo de trabalho é mapeado estritamente entre 125µs e 250µs. Com um clock de 50MHz, isso corresponde a uma contagem entre 6.250 e 12.500 ciclos de clock.

Seletor (Multiplexador) de Entrada: O sistema monitora a chave SW(0).

SW(0) em '0' : A velocidade é definida pelo valor enviado via computador através do IP In-System Sources and Probes (ISSP).

SW(0) em '1' : As entradas do Probe são ignoradas e a velocidade é ditada pelas chaves de aceleração.

Prioridade das Chaves: No modo manual, existe uma hierarquia de velocidade:

SW(3) (Máxima - 2000) > SW(2) (Média - 1500) > SW(1) (Mínima - 1000).

Visualização: O valor da velocidade atual (1000, 1500 ou 2000) é convertido para BCD e exibido nos displays de 7 segmentos (HEX0 a HEX3).

# Diagrama de blocos


###### Figura 1 - Diagrama de blocos 

![out](./Imagens/oneshot125-blockdiagram.svg) 

# Lógica do projeto
 Estado IDLE (Espera)
Neste estado, o sistema lê o comando de entrada (1000 a 2000). O sinal pwm_saida permanece em '0'. É aqui que o valor é processado para definir o largura_pulso em ticks de clock.

 Estado PULSO_ALTO (Execução)
O sinal pwm_saida é elevado para '1'.

O contador incrementa até atingir o valor calculado de largura_pulso.

Este estado garante a precisão de microssegundos exigida pelo OneShot125.

 Estado ESPERA_BAIXO (Finalização)
O sinal retorna para '0'.

O sistema aguarda o tempo restante para completar o ciclo antes de retornar ao estado IDLE e ler um novo comando.

# Máquina de estados

###### Figura 2 - Máquina de estados 

![out](./Imagens/oneshot125-statemachine.svg) 

Reset do Sistema: Através da chave SW(9), o sistema limpa todos os contadores e retorna à estaca zero.

Comutação de Fonte: Ao desligar SW(0), o sistema volta instantaneamente a exibir e utilizar o valor que estava sendo enviado pelo Probe, demonstrando a persistência do sinal de software no background.

Mapeamento de Saída: O sinal PWM resultante é encaminhado simultaneamente para o LEDR(0) e para o pino ARDUINO_IO(5), permitindo a análise em um osciloscópio real.


