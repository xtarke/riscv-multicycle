# Acelerador de Redes Neurais

Este periférico fornece os elementos básicos de uma rede neural artificial implementados em hardware, de forma à acelerar o processo de **inferência** da rede neural. O processo de treinamento não é comtemplado no períférico de deve ser realizado externamente. 

Os pesos dos neurônios podem ser configurados via software. A configuração por software das interconexões ainda não foi implementada, de forma que ainda não é possível utilizar o periférico para uma rede neural arbitrária.

## Projetos similares

Arquitecturas alternativas - entanda-se, não Von Neumann - são amplamentes utiilizadas para implementação de redes neurais, entre elas: 
* GPU (Graphics processing unit): circuitos especializados para processamento gráfico, mas cuja arquitetura altamente paralela se mostrou eficiente para processamento de diversos algoritmos paralelizáveis;
* TPU (Tensor Processing Unit): circuitos similares à GPUs porem otimizados para processamento de tensores (uma generalização matemática de vetores, muito utilizados em redes neurais);
* DNPU (Deep Neural Network Processing Unit) e similares: arquiteturas específicas para redes neurais.

Este trabalho inicia a implementação de um períférico do terceiro tipo. Tais implementações específicas possibilitam maior velocidade e eficiência energética [1], e há uma miríade de implementações, algumas puramente acadêmicas e outras disponíveis comercialmente.

A implementação the DNPU da KAIST (Korea Advanced Institute of Science and Technology), por exemplo, alega possuir uma eficiência energética 4 vezes maior do que TPUs existentes [4].

A implementação SYNAPSE-1  (Synthesis of Neural Algorithms on a Parallel Systolic Engine), por exemplo, utiliza multiplos processadores MA-16 da Siemens e promove uma aceleração de até 8000 vezes quando comparada à um computador tradicional [2].

Outros projetos ainda facilitam a implementação em FPGA de redes neurais específicas, como a Vitis AI da Xilinx [3, 6].

## Primitivas implementadas

Foram implementadas em hardware alguns elementos básicos usuamente utilizados em redes neurais:
* Produtos escalares;
* Funções de ativação;
* Neurônios (que combinam de forma conveniente os dois elementos anteriores).

Outras primitivas poderiam haver sido implementadas, como convoluções (muito utilizadas para processamento de imagem), dropout (um método de "morte" aleatória de neurônios), etc.

## Periférico de alto nível

O periférico em sí, a entidade topo deste projeto, instancia diversas primitivas e as deixa disponíveis para o programador C.

Foram implementados 3 neurônios do tipo perceptron, interconectados em uma rede neural com duas entradas e uma saída. Os dois primeiros neurônios recebem as duas entradas, a saída de cada um deles vai para as entradas do terceiro, e a saída desse é a saída da rede.

No futuro o periférico também deve ser responsável por configurar as interconexões entre as primitivas, por exemplo: o periférico foi sintetizado com 32 neurônios do tipo perceptron, 8 neurônios com ativação softmax e 8 neurônios com ativação linear; O programador decidiu utilizar 5 neurônios perceptron na camada de entrada, 3 em uma camada escondida, e 1 neurônio Softmax na camada de saída. 

No futuro pode ser necessário que as entradas sejam configuradas de forma sequencial, de forma à diminuir o espaço de endereçamento necessários para o barramento. Por exemplo: os peso são inseridos 8 à 8, cada conjunto de 8 sendo configurado em um ciclo de clock.

## Biblioteca C fornecida

Implementou-se uma biblioteca C para realizar a interface com o periférico, composta pelas seguintes funções:
* `void set_weigh(int8_t w0_0, int8_t w1_0, int8_t w0_1, int8_t w1_1, int8_t w0_2, int8_t w1_2);`: configura os pesos dos neurônios; Os íncices `x_y` representam a entrada `x` do neurônio `y`;
* `int8_t inference(int8_t x0, int8_t x1)`: recebe as entradas da rede, realizada a inferência, e retorna a saída da rede.

## Exemplo em C fornecido

Implementou-se um programa mínimo que configura a rede com pesos pré-definidos e realizada a inferência para um conjunto de valores de entrada.



## Simulação

Cada primitiva pode ser simulada e testada individualmente. Os testbenches já possuem asserções que verificam automaticamente o correto funcionamento das entidades.

Vale nota que muitas implementações são similares entre sí: `scalar_product_2` e `scalar_product_4`, por exemplo, diferem apenas no número de entradas. Nesses casos, o testbench contempla apenas uma das implementações, por brevidade. No futuro, talvez seja possível facilitar o desenvolvimento implementando uma única entidade genérica.

Para o periférico de alto nível apenas a simulação integrada com o core foi implementada.

## Síntese

?


## Referências



[1] Neural Networks in Hardware: A Survey. Yihua Liao.
[2] Ramacher, U., Raab, W., Anlauf, J., Hachmann, U., Beichter, J., Bruls, N., Webeling, M. and
Sicheneder, E., 1993, Multiprocessor and Memory Architecture of the Neurocomputers SYNAPSE-1.
Proceedings of the 3rd International Conference on Microelectronics for Neural Networks (Micro
Neuro), 227-231, 1993.
[3] https://towardsdatascience.com/neural-network-inference-on-fpgas-d1c20c479e84
[4] http://koreabizwire.com/kaist-develops-new-ai-chip-capable-of-deep-learning/93050
[5] https://www.youtube.com/watch?v=CdH2p6mJnYk
[6] https://www.xilinx.com/products/design-tools/vitis/vitis-ai.html
[7] An FPGA Implementation for convolutional neural network. Guilherme dos Santos Korol. Pontífice Universidade Católica do Rio Grande do Sul.