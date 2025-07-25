# I2C
---
 
Assim como na comunicação assíncrona, o I²C utiliza dois canais para comunicação.
I²C significa Inter-Integrated Circuit (Circuito Inter-Integrado) e pode ser pronunciado como “I dois C”. Ele foi criado pela Philips, tendo como vantagem a simplicidade e o baixo custo, e, como desvantagem, a velocidade.
Em relação aos dois canais de comunicação, temos: o canal de dados seriais, chamado de serial data (SDA); e o canal de sincronização, chamado serial clock (SCL). 
Os dois canais de comunicação são bidirecionais. O mestre é responsável por coordenar a comunicação (gerar clock e iniciar a comunicação).
 
 
 ### clk 100 kHz
 
 ### clk_scl 100 kHz (90º defasado)

 
## I2C_Master(hardware):

![](https://www.electronicshub.org/wp-content/uploads/2018/02/Basics-of-I2C-Communication-Masters-Slaves.jpg)

![](https://www.electronicshub.org/wp-content/uploads/2018/02/Basics-of-I2C-Communication-Data-Transfer-Protocol.jpg)


![](https://upload.wikimedia.org/wikipedia/commons/thumb/6/64/I2C_data_transfer.svg/600px-I2C_data_transfer.svg.png)


![](https://github.com/jhonatanlang/riscv-multicycle/blob/master/peripherals/i2c_master/images/rtl_block.png)

### I2C_Write_Machine


![](https://github.com/jhonatanlang/riscv-multicycle/blob/master/peripherals/i2c_master/images/state_machine.png)

Simulação do periférico:
![](https://github.com/jhonatanlang/riscv-multicycle/blob/master/peripherals/i2c_master/images/periferic_simulation.png)

Simulação de Leitura:
![](https://github.com/Emanuel600/riscv-multicycle/blob/dev/peripherals/i2c_master/images/i2c_read-sim.png)

Simulação do periférico integrado ao softcore:
![](https://github.com/jhonatanlang/riscv-multicycle/blob/master/peripherals/i2c_master/images/simulation.png)

Aquisição de osciloscópio: escrevendo 0x01 em display LCD 16x2 com extensor de IO:
![](https://github.com/jhonatanlang/riscv-multicycle/blob/master/peripherals/i2c_master/images/osciloscope.png)

## Getting Started (software):

Biblioteca

	i2c_master.h	

	i2c_master.c
	
		int I2C_write(uint8_t data, uint8_t addr); -- função para escrever 1 byte
	
Arquivo exemplo	

	main_i2c_master.c   
