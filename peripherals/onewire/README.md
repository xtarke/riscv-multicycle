# Protocolo One-wire

Este projeto visa a implementação do protocolo de comunicação one-wire utilizando VHDL. 

O protocolo one-wire é um padrão de comunicação serial utilizado para conectar dispositivos eletrônicos de forma que possam ser controlados e alimentados por um único fio de dados, além de possuírem identificação única. Ele é comumente usado em sensores de temperatura, memórias EEPROM e outros dispositivos eletrônicos de baixo custo e baixo consumo de energia. O protocolo permite que múltiplos dispositivos sejam conectados ao mesmo barramento de comunicação.

A temporação utilizada neste projeto foi baseada na documentação do sensor DS18B20, um sensor de temperatura de baixo custo que utiliza o protocolo one-wire para comunicação

Para implementarmos esse protocolo foi criada a seguinte máquina de estados, representada na figura abaixo.

![](https://raw.githubusercontent.com/ericreis27/riscv-multicycle/master/peripherals/onewire/figures/diagram_onewire.png)

O protocolo one-wire segue temporizações rigorosas para que os dados possam ser transmitidos de forma correta. Abaixo iremos descrever o funcionamento do protocolo em paralelo com a máquina de estados criada.

### Procedimento de inicialização

No protocolo OneWire, a inicialização começa quando o mestre (o dispositivo controlador) envia um pulso de reset para a linha de dados. Durante a inicialização, o mestre envia um pulso de reset por um determinado periodo de tempo e espera a resposta de algum dispositivo no barramento de dados, esse processo ocorre entre os estados __RESET, SAMPLE DEVICE RESPONSE e DEVICE RECOVERY RESPONSE__. Caso dentro de uma janela específica de tempo algum dispositivo não puxe o barramento de dados para o GND sinalizando sua presença, a máquina de estados volta para o estado IDLE e reinicia o processo de inicialização buscando novamente por um dispositivo. Caso obtenha a resposta de algum dispositivo, a máquina prossegue para a fase de escrita no barramento. A figura a seguir demonstra a temporização e como funciona esse procedimento.

![](https://raw.githubusercontent.com/ericreis27/riscv-multicycle/master/peripherals/onewire/figures/initialization_onewire.png)

### WRITE
Durante a escrita, desejamos enviar algum comando para que o dispositivo nos responda com os dados requisitados. Esse envio é feito seguindo um protocolo restrito de temporização para o envio de cada bit do comando. Abaixo segue as especificações de temporização utilizadas para o envio de um bit.

![](https://raw.githubusercontent.com/ericreis27/riscv-multicycle/master/peripherals/onewire/figures/write_time_slot.png)

O envio dos bits é feito entre os estados __MASTER WRITE, MASTER WRITE SLOT E MASTER WRITE RECOVERY__, onde será iterado em cada um dos bits do comando de escrita e serão enviados para o dispositivo. Após o envio do comando entramos num estado __MASTER POST WRITE DELAY__ antes de iniciarmos o processo de leitura.

### READ
Da mesma forma que a escrita, a leitura da resposta do dispositivo segue temporização rigorosa. Abaixo seguem dois diagramas detalhando melhor as especificações utilizadas durante o processo de leitura.

![](https://raw.githubusercontent.com/ericreis27/riscv-multicycle/master/peripherals/onewire/figures/read_time_slot.png)

![](https://raw.githubusercontent.com/ericreis27/riscv-multicycle/master/peripherals/onewire/figures/recommended_read_timings.png)

Durante o processo de escrita iremos ciclar entre os estados __MASTER READ, MASTER AWAIT READ SAMPLE E MASTER READ RECOVERY__, atuando de forma cíclica extremamente similar a como fazemos o processo de escrita, porém trabalhando com temporizações diferentes. Após a leitura de todos os bits de resposta do dispositivo finalmente vamos para um estado de recuperação __MASTER POST READ DELAY__ e finalmente chegamos no fim da implementação do protocolo no estado __DONE__.

### ToDo
Atualmente foi implementado o envio e leitura de dados utilizando a temporização adequada do protocolo, porém demonstrando a leitura e escrita utilizando valores **hardcoded**. A adequação do projeto para que ele possa enviar qualquer tipo de comando e também tratar os dados adequadamente seria o próximo passo importante neste projeto

