# Teclado Matricial de Membrana

Esta implementação contempla o uso de um teclado matricial como periférico. Para demonstrar seu funcionamento, a imagem da tecla pressionada é exibida no display de 7 segmentos da FPGA.

![Teclado Matricial](https://github.com/luiz-sene/riscv-multicycle/blob/master/peripherals/keyboard/figures/teclado_matricial_membrana_4x4.jpg)

Este periférico possui 8 pinos, sendo os 4 mais significativos relacionados às 4 linhas e os 4 menos significativos as 4 colunas. Dessa forma envia-se um pulso em nível baixo uma linha por vez, e quando um número é pressionado a coluna em que a tecla pertecence muda seu valor de 1 para 0. Sabendo então a linha e a coluna que possuem valor 0 pode-se determinar a tecla que foi pressionada. Conforme imagem abaixo.

![Funcionamento](https://github.com/luiz-sene/riscv-multicycle/blob/master/peripherals/keyboard/figures/272_img_5_H.png)

Para realizar o varrimento das linhas foi utilizado uma máquina de estados com a seguinte configuração:
![Maquina de estados](https://github.com/luiz-sene/riscv-multicycle/blob/master/peripherals/keyboard/figures/maquina_estados.png)

Onde após iniciar, cada estado corresponde a um dos 4 bits das linhas como valor 0, e em cada estado é verificado se o valor de alguma coluna é igual a 0.


# Simulação
A primeira simulação foi feita ainda antes do periférico ser implementado no projeto como um todo e pode ser visto nos arquivos [testbench2.vhd](https://github.com/luiz-sene/riscv-multicycle/blob/master/peripherals/keyboard/testbench2.vhd) e [testbench2.do](https://github.com/luiz-sene/riscv-multicycle/blob/master/peripherals/keyboard/testbench2.do)

# Circuito
O teclado é ligado diretamente aos pinos GPIO da FPGA conforme a imagem abaixo, sendo os fios laranjas os das linhas do teclado e os azuis das colunas.

![circuito](https://github.com/luiz-sene/riscv-multicycle/blob/master/peripherals/keyboard/figures/de10teclado2.png)

# Referências
* [Usando teclado matricial com Arduino](https://www.robocore.net/tutoriais/usando-teclado-matricial-com-arduino).
