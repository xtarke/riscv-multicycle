## Softcore Servo Motor

O desenvolvimento do controle do servo motor foi realizado com base em um trabalho já existente no repositório, denominado servo_motor, o qual foi adaptado para funcionamento em um softcore RISC-V. A partir desse projeto, foi criado um arquivo de barramento específico (servo_bus) na pasta peripherals, que posteriormente foi instanciado no sistema com o objetivo de permitir a comunicação entre o software e o periférico.

Inicialmente, o funcionamento do periférico foi verificado por meio de simulação no ModelSim, analisando os sinais PWM e rotate. Como o tempo total de simulação foi inferior a meio período do sinal PWM, não foi possível observar a variação completa do PWM nas imagens geradas. No entanto, foi possível visualizar corretamente a variação do sinal rotate, conforme definido no código em linguagem C.

<img width="1423" height="599" alt="Captura de tela 2025-12-18 212531" src="https://github.com/user-attachments/assets/69bb7a1b-f271-4d2b-837e-6bd7ecd80547" />

Após a validação por meio de simulação, o projeto foi implementado em hardware utilizando o Quartus, tendo como base o exemplo do periférico GPIO disponível no repositório. Esse exemplo foi adaptado para permitir a utilização do servo_bus, onde a saída do sinal PWM foi instanciada no pino ARDUINO_IO(0). A correta integração do periférico ao sistema pôde ser confirmada por meio do RTL Viewer, onde é possível visualizar a instância do barramento do servo devidamente conectada à arquitetura do processador.

<img width="428" height="365" alt="Captura de tela 2025-12-18 212555" src="https://github.com/user-attachments/assets/4d0d60bc-623c-46f0-8631-1fabc2272da4" />

<img width="597" height="280" alt="Captura de tela 2025-12-19 065428" src="https://github.com/user-attachments/assets/36cc73d2-71a3-49e1-8bcb-81e8409e72c5" />

Por fim, o projeto foi executado em hardware, sendo necessária apenas a modificação do arquivo em linguagem C para a inclusão de um atraso (delay), seguida da regeneração do arquivo .hex. Esse arquivo foi carregado na placa e o sistema foi testado experimentalmente com o auxílio de um osciloscópio. Os sinais observados apresentaram o comportamento esperado do sinal PWM, confirmando que o sistema funcionou corretamente tanto em simulação quanto em ambiente real.

![TEK0031](https://github.com/user-attachments/assets/55c1b19f-4909-4b9d-9516-29140086871d)
