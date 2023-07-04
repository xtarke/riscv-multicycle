# README Periféricos GPIO

Este é um README para documentar os periféricos presentes na pasta GPIO.

## GPIO

O *GPIO* (General Purpose Input/Output) é responsável por lidar um GPIO de propósito geral. Ele é utilizado para trabalhar com interrupções, registradores de entrada e registradores de saída.

## LED Displays

O *led_displays* converte um valor presente no *ddata_w* para ser apresentado em um display de 7 segmentos presente na placa de10lite. Esse componente é responsável por exibir o valor desejado no display de forma apropriada(o valor será exibido no display na base hexadecimal).

## Temp

O *temp.vhd* é responsável por converter um valor para a base decimal e apresentá-lo em um display de 7 segmentos. Foi criada uma função para converter o valor presente em *ddata_w* na base decimal e, em seguida, apresentar o valor convertido no display de 7 segmentos.

A função recebe o valor presente em *ddata_w* e o transforma em um número na base decimal. No caso desse projeto, a leitura é feita usando um conversor analógico-digital (ADC) conectado a um sensor de temperatura (LM35). A função basicamente subtrai 10 do valor da variável *temp* e possui um contador responsável por registrar quantas vezes 10 foi subtraído do valor de *temp*. Se *temp* for menor que 10, o programa sai do loop.

A função retorna o valor do contador e, em seguida, o valor convertido é enviado para outra função responsável por apresentar o valor em decimal no display de 7 segmentos. No arquivo *temp.vhd*, esse componente é utilizado para apresentar a temperatura medida pelo sensor nos displays de 7 segmentos, tanto em graus Celsius como em graus Fahrenheit (por exemplo, 12°C/53°F).
