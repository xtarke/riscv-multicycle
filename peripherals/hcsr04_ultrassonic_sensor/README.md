  O presente trabalho consiste na migração do periférico de um sensor ultrassônico (modelo HCSR04) da arquitetura RISC-V anterior (2.2) para a versão atualizada (2.3). A partir desta arquitetura será criado um microcontrolador em hardware para gerenciar o periférico escolhido, que posteriormente será simulado no ambiente ModelSim. O código base da arquitetura RISC-V foi disponibilizado pelo professor desta disciplina, já o código base do sensor ultrassônico foi adaptado e baseado no código do repositório disponibilizado também pelo professor desta disciplina. 
	O HCSR04 é um sensor ultrassônico facilmente encontrado e altamente difundido e para o projeto, deve-se considerar as distâncias máxima (400 cm) e mínima (2 cm), além da duração mínima do pulso de trigger (10 µs). O funcionamento do sensor consiste no envio de um pulso ultrassônico de 40 kHz por meio do transdutor emissor. Esse sinal viaja pelo ar até encontrar um obstáculo, sendo então refletido de volta ao sensor. O transdutor receptor capta esse eco e contabiliza o tempo decorrido entre o envio e o recebimento da onda sonora. Durante esse período, o pino Echo é mantido em nível alto, indicando o tempo que a onda levou para retornar ao sensor após a reflexão no obstáculo. Para iniciar uma medição, o microcontrolador deve enviar um pulso de nível alto no pino trigger, com duração mínima de 10 µs. Esse pulso ativa o sensor, iniciando a emissão da onda ultrassônica. 

# Sensor Ultrassônico HC-SR04
(https://cdn.sparkfun.com/datasheets/Sensors/Proximity/HCSR04.pdf), 

<kbd>DIAGRAMA DE TEMPO![DiagramaTempo](https://github.com/lirahc/hcsr04_pld_ultrassonic/assets/49963038/ec08f287-c4fc-4ad3-9d37-afcda94749b8)</kbd>

- Para isso, gerou-se uma máquina de estados, representada na figura abaixo.

<kbd>MAQUINA DE ESTADOS![maquina_de_estados](https://github.com/lirahc/hcsr04_pld_ultrassonic/assets/49963038/d9e81335-5bad-4bd1-9e12-e6f57d76553d)</kbd>

## Simulação
- Para a simulação, gerou-se dois arquivos de teste. O arquivo [testbench2.vhd](/peripherals/hcsr04_ultrassonic_sensor) , sendo possível visualizar a mudança dos estados e o contador de pulsos do sinal de entrada echo.

## Montagem do circuito
- Este sensor necessita de tensão de entrada de 5V para seu funcionamento adequado. Por isso, para a montagem do circuito, utilizou-se um conversor de nível lógico de 5V a 3V3 bidirecional, conforme apresentado abaixo.
- Os pinos echo e trigger são conectados aos pinos do ARDUINO_IO 0 e 1, respectivamente.
<kbd>MONTAGEM DO CIRCUITO![Montagem_Circuito](https://github.com/lirahc/hcsr04_pld_ultrassonic/assets/49963038/b922cfb7-0732-47e0-84f6-5f686ca8940d)<kbd>

## Resultados da síntese
- A figura abaixo foi retirado com o auxílio de um analisador lógico. Nesta, pode ser visto o sinal de trigger de 10 us e o sinal de echo gerado pelo sensor.
<kbd>SIMULAÇÃO![SIMULAÇÃO](https://github.com/lirahc/hcsr04_pld_ultrassonic/assets/49963038/53c80034-e160-429f-b757-f160ba7e3769)<kbd>

## Teste Prático
### Distância de 05 cm.
<kbd>![osc_small_onda](https://github.com/lirahc/hcsr04_pld_ultrassonic/assets/49963038/1ae7c6e8-e484-4fdb-81b3-f5fc703d5f0d)<kbd>

### Distância de 15 cm.
<kbd>![osc_big_onda](https://github.com/lirahc/hcsr04_pld_ultrassonic/assets/49963038/bfcf183d-06a4-4807-a2d7-b30557ede34b)<kbd>

### Disposição Trig & Echo
<kbd>![osc_2_onda](https://github.com/lirahc/hcsr04_pld_ultrassonic/assets/49963038/91d3e51a-c8cf-45a9-a008-ebd8bd8690b5)<kbd>

## ToDo
- Na síntese, observou-se que após um determinado tempo, ele parava de realizar a contagem e necessitava de reset. Por isso, posteriormente é necessário analisar o sinal de echo no osciloscópio para verificar uma possível perda de descida deste sinal. Sendo assim, o *Trigger* funciona num período de 10us sendo o período de 60ms do sistema, antes disso o sistema está em *Idle*, após o período de Trigger o sistema está enable e o sinal *Echo* está disponível para captação do sinal para validação do sensor, como pode ser visto na figura a seguir o sistema.



