# Conclusão

Neste trabalho foi desenvolvido um sistema de animação de LEDs em FPGA,
utilizando a linguagem VHDL e conceitos fundamentais de dispositivos lógicos programáveis.
A proposta consistiu na implementação de uma “barrinha” de LEDs com
controle de intensidade luminosa por meio de modulação por largura de
pulso (PWM), coordenada por uma máquina de estados finita (FSM).

A decomposição do projeto em blocos funcionais — divisor de clock, gerador
de PWM e FSM — permitiu uma abordagem modular, facilitando o
desenvolvimento, a verificação individual dos módulos e a integração
final do sistema. A utilização de um divisor de clock possibilitou a
observação clara da evolução dos estados, enquanto o gerador de PWM
proporcionou diferentes níveis de brilho, tornando a animação mais rica
do ponto de vista visual.

A validação por simulação no ambiente ModelSim confirmou o funcionamento
esperado da FSM, a correta geração dos sinais PWM e a atuação adequada
dos sinais de controle, como `enable`, `progr_regr` e `reset`. A posterior
implementação em hardware, na placa FPGA DE10-Lite, demonstrou coerência
entre os resultados simulados e o comportamento observado fisicamente,
evidenciando o sucesso da implementação.

Dessa forma, o projeto permitiu consolidar os conhecimentos abordados na
disciplina, especialmente no que se refere à descrição de hardware em
VHDL, ao uso de máquinas de estados finitas e à integração entre simulação
e implementação em FPGA. Além disso, o sistema desenvolvido apresenta uma
arquitetura organizada e reutilizável, podendo servir como base para
extensões futuras, como a inclusão de novos efeitos visuais ou formas
adicionais de controle.

