# Metodologia

A metodologia adotada neste trabalho baseia-se no desenvolvimento modular
de um sistema digital em FPGA, descrito em linguagem VHDL, seguido de
validação por simulação e implementação em hardware. O projeto foi
organizado em blocos funcionais independentes, o que facilita a
compreensão, depuração e reutilização do código.

O controle da animação dos LEDs é realizado por meio de uma máquina de
estados finita (FSM), responsável por definir a quantidade de LEDs ativos
e o sentido da animação. A FSM foi modelada utilizando o modelo de Moore,
em que as saídas dependem exclusivamente do estado atual do sistema. A
Figura a seguir apresenta o diagrama de estados da FSM, no qual é possível
visualizar os estados, as transições e a lógica de progressão e regressão
da animação.

FIGURA 1

O sistema também conta com um bloco dedicado à divisão do clock da FPGA,
cuja função é reduzir a frequência do sinal de clock principal para
valores adequados ao funcionamento da FSM e à visualização da animação
dos LEDs. Esse bloco recebe como entradas o clock da placa e o sinal de
reset, e fornece como saída um clock dividido. O diagrama de bloco do
divisor de clock, com suas respectivas entradas e saídas, é apresentado
na Figura a seguir.

FIGURA 2

Para o controle do brilho dos LEDs, foi desenvolvido um módulo gerador de
PWM, responsável por produzir sinais com diferentes ciclos de trabalho.
Neste projeto, são utilizados sinais PWM com duty cycles de 10%, 30%,
60% e 90%, permitindo a variação da intensidade luminosa dos LEDs de forma
discreta. O módulo recebe como entradas o clock e o reset, e fornece como
saídas os sinais PWM correspondentes. A Figura a seguir ilustra o diagrama de
bloco do gerador PWM, evidenciando suas entradas e saídas.

FIGURA 3

O sistema dispõe de três chaves de controle externas: reset, enable e
progr_regr. O sinal de reset é responsável por reinicializar o sistema,
forçando a FSM ao estado inicial. A chave enable habilita ou bloqueia a
atualização dos estados, permitindo pausar a animação dos LEDs. Por fim,
a chave progr_regr define o sentido da animação, possibilitando a
progressão ou regressão da “barrinha” de LEDs.

A validação funcional do sistema foi realizada por meio de simulações no
ambiente ModelSim. Para automatizar esse processo, foi utilizado um
script de simulação (`script.do`), responsável por recriar a biblioteca
de trabalho, compilar os módulos VHDL, iniciar a simulação do testbench e
configurar a visualização dos sinais na forma de onda. A simulação foi
executada por um intervalo de tempo suficiente para observar o
funcionamento completo da animação dos LEDs e a variação dos sinais PWM.

Após a etapa de simulação, o projeto foi sintetizado e implementado em
uma placa FPGA DE10-Lite, utilizando o software Quartus. Essa etapa
permitiu verificar o funcionamento do sistema em hardware real,
confirmando os resultados observados durante a simulação.
