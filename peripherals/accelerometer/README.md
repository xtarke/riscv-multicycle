# Acelerômetro

A placa de desenvolvimente **DE10 Lite** contém o acelerometro [ADXL345](https://www.analog.com/media/en/technical-documentation/data-sheets/ADXL345.pdf)  integrado em seu hardware, do qual foi implementado esse periférico.
![enter image description here](https://i.imgur.com/oreIfIh.jpg)

O ADXL345 tanto pode se comunicar por I2C ou SPI. Foi implementado esse periférico em **SPI**. Os valores dos três eixos (x, y e z) são disponibilizados no formato **16 bits**, com **complemento de 2** para representar os valores negativos. 
![enter image description here](https://i.imgur.com/dhzW9L0.png)

## Periférico isolado
Antes de integrar o periférico ao softcore, o acelerômetro foi testado isoladamente.

Obs: para rodar o projeto SEM o core, na configuração do acelerometro o spi_cont fica em 0. Para rodar o projeto COM o core, na configuração do acelerometro o spi_cont fica em 1. Linha 152, do arquivo accelerometer_adxl345.vhd

```vhdl 
	if (spi_busy = '0') then --transaction not started
                -- continuos yes, ss_n continuos
                -- continuos not, ss_n pulse
                spi_cont    <= '1'; --set SPI continuous mode 

```

### Máquina de estados
Foi utilizado o driver do ADXL345 fornecido pela [digikey](https://www.digikey.com/eewiki/download/attachments/90243412/pmod_accelerometer_adxl345.vhd?version=1&modificationDate=1568909638756&api=v2).
![enter image description here](https://i.imgur.com/gC1zdSb.png)

### Bloco VHDL
O ADXL345 desempenha o papel de SLAVE na comunicação, ao periférico cabe a função de MASTER e tratar a lógica da disponibilização dos dados.
![enter image description here](https://i.imgur.com/Cd8z06F.png)

### Simulação do periféricos sem o softcore
Para simular o periférico foi gerados valores para os eixos via SPI SLAVE.
![enter image description here](https://i.imgur.com/4e1S893.png)

## Integração ao softcore
### Parte 1 - VHDL
Esse periférico fornecer os valores do eixos, então o softcore precisa **ler** esses dados.
Foi adicionado ao módulo do acelerômetro um processo de leitura.
![enter image description here](https://i.imgur.com/BtfjbBg.png)
> Os endereço x"80", x"81" e x"82" estão configurados (hardware.h) conforme endereço base 8*16=128 (decimal)

Para generalização do softcore e periféricos foi agregado ao bloco do acelerômetro os sinais que envolvem a manipulação do barramento.
![enter image description here](https://i.imgur.com/STL6NcP.png)

O código em C projetado direciona os valores para o periférico GPIO, assim os endereços da GPIO e do acelerômetro foram configurados.
![enter image description here](https://i.imgur.com/0ubDx7c.png)

Os valores dos eixos são colocados nos displays de 7 segmentos.
Para testes foi configurado uma chave que permite alterar entre os dados passarem ou não pelo softcore.
![enter image description here](https://i.imgur.com/G8mrunJ.png)

### Parte 2 - C
Em hardware.h as definição dos endereços utilizados:
```c 
#define PERIPH_BASE		((uint32_t)0x4000000) 

#define IONBUS_BASE_ADDRESS 		(*(_IO32 *) (PERIPH_BASE))
#define ACCELEROMETER_BASE_ADDRESS	(*(_IO32 *) (PERIPH_BASE + 8*16*4))
```

> Esse endereço base do acelerômetro 8*16=128 (decimal) é utilizado no processo de leitura (accel_bus.vhd) desse periférico.
No processo de leitura o endereço base e os endereços posteriores estão expressos em hexadecimal, x"80", x"81" e x"82"

#### Os protótipos das funções e definições
```c 
typedef struct
{
                 // .h, .vhd
	_IO32 axe_x; //	128, x80
	_IO32 axe_y; //	129, x81
	_IO32 axe_z; //	130, x82
} ACCEL_TYPE;

#define ACCEL ((ACCEL_TYPE *) &ACCELEROMETER_BASE_ADDRESS)

uint32_t read_axe_x(void);
uint32_t read_axe_y(void);
uint32_t read_axe_z(void);
```

#### Funções implementadas
```c 
uint32_t read_axe_x(void)
{
	return ACCEL -> axe_x;
}

uint32_t read_axe_y(void)
{
	return ACCEL -> axe_y;
}

uint32_t read_axe_z(void)
{
	return ACCEL -> axe_z;
}
```

#### Código para testar o funcionamento do periférico
```c 
#include "accelerometer.h"

int main(void)
{
    while(1)
    {
		OUTBUS = read_axe_x();
		delay_(100000);
		OUTBUS = read_axe_y();
		delay_(100000);
		OUTBUS = read_axe_z();
		delay_(100000);
    }
	return 0;
}
```
