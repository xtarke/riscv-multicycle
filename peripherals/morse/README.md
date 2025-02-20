# MorseCode Numbers

Esta implementação contempla o uso de um módulo buzzer (figura abaixo) como periférico. Que recebe um sinal de entrada e converte para um sinal sonoro itermitente que é representado por pontos e traços. Atualmente está implementado os números do código morse.


![# modulo buzzer ](./imagens/modulo%20buzzer.png)



O ponto tem o periodo de T e o traço 3T emitindo som, intervalo entre caracter tem 3T e entre palavras 7T. O período T pode variar de acordo com a experiência do operador de código morse. A seguir a tabela de código morse implementada:

![numeros morse](./imagens/Morse_code_numbers.png)

Este periférico possui 3 pinos, VCC de 3V3, GND e o pino de controle, no qual envia um sinal que emite som quando '0' e fica sem som quando '1'

Utilizou-se uma tabela para converter a entrada em pontos e traços (pontos são represnetados por '0' traços representados por '1') e uma maquina de estados para realizar os diferentes periodos de operação. A maquina de estados a seguir resume a operação deste programa


![maquina de estados ](./imagens/Maquina_de_estados.png)

# Simulação
A primeira simulação foi feita ainda antes do periférico ser implementado no projeto como um todo e pode ser visto nos arquivos [testbench](/peripherals/morse/testbench.vhd) e [tb.do](/peripherals/morse/tb.do)

# Simulação Softcore
Criado o barramento para a integração com o softcore e feito um código em C para enviar os dados e comunicar com o barramento, na imagem abaixo tem o envio do dado para o periferico.

![maquina de estados ](./imagens/Maquina_de_estados.png)
