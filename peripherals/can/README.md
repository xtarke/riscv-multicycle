# Controlador CAN

Este projeto implementa um controlador CAN baseado no **MCP2515** da **Microchip Technology**.

O **MCP2515** implementa a camada de enlace do protocolo CAN. Possui interface SPI para escrita e leitura de seus registradores; no entanto, necessita de um circuito que implemente a camada física (ISO 11898), como o **MCP2551** ou **TJA1050**. 

Algumas mudanças foram necessárias em relação ao **MCP2515** para que o mesmo se enquadre como um periférico de um **RISC-V** de 32 bits:
- O **MCP2515** apresenta interface SPI. No projeto, a comunicação ocorre pelos barramentos de dados do processador de forma paralela, em blocos de 8 bits.
- Os registradores **CNFn**, responsáveis pelo baud rate e pela amostragem, foram abstraídos em um único registrador denominado **BAUD_REG**.
- O **MCP2515** conta com três buffers distintos de dados para o envio de diferentes *CAN frames* com prioridade personalizada. No entanto, neste projeto foi implementado apenas o *buffer* "0", que inicia o envio da mensagem assim que o barramento CAN é considerado desocupado.

Ressalta-se que o periférico desenvolvido implementa um controlador CAN apenas para transmissão (TX) em *one-shot mode*. Ele suporta quadros no formato CAN 2.0A (identificador de 11 bits), taxa de transmissão configurável via prescaler. A interface com o barramento do RISC‑V é realizada por meio de um mapa de registradores, acessível através do espaço de periféricos.

Para versões futuras, sugere-se a implementação da recepção de quadros (RX) e dos demais modos de operação presentes no MCP2515 (*Normal mode, Sleep mode e Listen-Only mode*).

Abaixo, uma imagem representativa das entidades do periférico em diagrama de blocos:

![image](img/diagrama.png)

- **register_map.vhd** -> Responsável por armazenar os dados de configuração, IDs de mensagens, flags de status e os payloads (TX), atuando como interface de memória entre o processador e o controlador CAN.
- **can_engine.vhd** -> Responsável por gerenciar a camada física e temporal do barramento, executando o *bit stuffing*, a geração do *baud rate* e a interface direta com o *transceiver* (pinos TX e RX).
- **can_fsm.vhd** -> Responsável pela lógica do protocolo, controlando a máquina de estados sequencial para a correta montagem dos campos do quadro CAN (SOF, Arbitragem, Dados, CRC, ACK e EOF).
- **top_level.vhd** -> Responsável por instanciar e interconectar todos os submódulos do projeto, expondo apenas a interface de comunicação com o processador e o *transceiver*.


# Simulação do componente

Para verificar o funcionamento isolado do periférico, execute o script [tb.do](/peripherals/can/tb.do) no ModelSim/Questa. Esse testbench instancia apenas o `can_top` e estimula diretamente seus sinais.

resultado
![image](img/tb.png)
falar do resultado
# maquina de estados
descrever brevemente cada um
![image](img/fsm.png)

# Simulação com o RISCV
- Compilar o código de teste `software/can/can_main.c` ou usar o 'can.hex' previamante compilado
certificar que no tb_riscv.vhd em iram_inst indicam o .hex do formato certo e esta no caminho correto em relação a tb.do e que iram tem um generic que o suporte

resultado
![image](img/tb_riscv.png)
falar do resultado