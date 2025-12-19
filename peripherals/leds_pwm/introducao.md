# Introdução

Este trabalho apresenta o desenvolvimento de uma animação de LEDs utilizando
lógica programável em FPGA, empregando a linguagem de descrição de hardware
VHDL. O objetivo principal consiste na implementação de uma “barrinha” de LEDs,
cujo brilho é controlado por modulação por largura de pulso (PWM), coordenada
por uma máquina de estados finita (FSM). Essa abordagem permite variar tanto
a quantidade de LEDs acesos quanto a intensidade luminosa de cada um.

O projeto foi estruturado de forma modular, contemplando blocos específicos
para divisão de clock, geração dos sinais PWM e controle da animação por meio
da FSM. A validação funcional foi realizada por meio de simulações no ambiente
ModelSim, enquanto a implementação física ocorreu em uma placa FPGA DE10-Lite,
utilizando o software Quartus para a síntese e gravação do projeto. Dessa forma,
o trabalho integra os conceitos estudados na disciplina, resultando em uma
aplicação prática e visualmente intuitiva.
