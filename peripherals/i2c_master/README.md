# I2C
---
 
Assim como na comunicação assíncrona, o I²C utiliza dois canais para comunicação.
I²C significa Inter-Integrated Circuit (Circuito Inter-Integrado) e pode ser pronunciado como “I dois C”. Ele foi criado pela Philips, tendo como vantagem a simplicidade e o baixo custo, e, como desvantagem, a velocidade.
Em relação aos dois canais de comunicação, temos: o canal de dados seriais, chamado de serial data (SDA); e o canal de sincronização, chamado serial clock (SCL). Simplificadamente, o Clock é um sinal que oscila entre nível alto e baixo rapidamente. Então, essa oscilação é utilizada para sincronizar os dispositivos a cada vez que o clock apresentar certo estado. 
Os dois canais de comunicação são bidirecionais. O mestre é responsável por coordenar a comunicação (gerar clock e iniciar a comunicação).
 
 
 
## I2C_Master(hardware):

![](https://github.com/jhonatanlang/riscv-multicycle/blob/master/peripherals/i2c_master/images/i2c_barramento.PNG)
![](https://github.com/jhonatanlang/riscv-multicycle/blob/master/peripherals/i2c_master/images/protocol.png)
![](https://github.com/jhonatanlang/riscv-multicycle/blob/master/peripherals/i2c_master/images/protocol_diagram.png)
![](https://github.com/jhonatanlang/riscv-multicycle/blob/master/peripherals/i2c_master/images/rtl_block.png)

### I2C_Write_Machine
![](https://github.com/jhonatanlang/riscv-multicycle/blob/master/peripherals/i2c_master/images/state_machine.png)
![](https://github.com/jhonatanlang/riscv-multicycle/blob/master/peripherals/i2c_master/images/periferic_simulation.png)
![](https://github.com/jhonatanlang/riscv-multicycle/blob/master/peripherals/i2c_master/images/simulation.png)
![](https://github.com/jhonatanlang/riscv-multicycle/blob/master/peripherals/i2c_master/images/osciloscope.png)


## Getting Started (software):

int write_i2c( addr, data)
