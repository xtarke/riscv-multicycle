# Teclado Matricial de Membrana

Esta implementação contempla o uso de um teclado matricial como periférico. 
IMAGEM
Este periférico possui 8 pinos, sendo os 4 mais significativos relacionados as 4 linhas e os 4 menos aos menos significativos as 4 colunas. Dessa forma envia-se um pulso em nivel baixo uma linha por vez, e quando um numero é pressionado a coluna em que a tecla pertecence muda seu valor de 1 para 0. Sabendo então a linha e a coluna que possuem valor 0 pode-se determinar a tecla que foi pressionada. Conforme imagem abaixo.
IMAGEM
Para realizar o varrimento das linhas foi utilizado uma maquina de estados com a seguinte configuração:
IMAGEM
