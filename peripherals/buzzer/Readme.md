### Periférico Buzzer:

Autor: Caio Neves Meira
Data: 31/07/2025

Buzzer.vhd tem a função de tocar a música Marcha imperial em um buzzer Ativo.

Foram definidos os seguintes pinos para o projeto:

SW(3) -> Reset
Arduino(0) -> GPIO Buzzer

O buzzer precisa estar alimentado com 3v3.


### Funcionamento do Projeto

Cada nota é composta por dois estados (ex: S1 e S2), sendo que um deles remete-se ao tempo com o buzzer apitando e ou outro com o tempo dele sem fazer barulho.

O Código fica passando os estados de maneira sequencial, tocando "nota" por "nota" até concluir o som.

A música em questão utilizada, usou 86 estados.


### Dicas para a próxima pessoa que deseja prosseguir com o projeto

Recomendo fortemente fazer o uso de um buzzer passivo em vez de um buzzer ativo, visto que o mesmo tem a capacidade de mudar o tom do apito, coisa que o ativo não possui.

Existe uma função ms no projeto, que serve pra "transformar" o tempo de clock em tempo real, em específico milisegundos.

