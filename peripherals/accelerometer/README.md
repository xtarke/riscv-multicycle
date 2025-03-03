
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
Esse periférico fornece os valores do eixos e o maior valor lido em cada eixo desde o último reset, então o softcore precisa **ler** esses dados.
Foi adicionado ao módulo do acelerômetro um processo de leitura.

```vhdl
  -- insert the values ​​on the core bus
  process (clk, rst)
    begin
    if rst = '1' then
      ddata_r <= (others => '0');
    else		
      if rising_edge(clk) then
			if (d_rd = '1') and (dcsel = MY_CHIPSELECT) then
        -- #define ACCELEROMETER_BASE_ADDRESS (*(_IO32 *) (PERIPH_BASE + 18*16*4))
        -- 18*16 = 244 (decimal) -> 0x0120 (hexadecimal)
				if    daddress(15 downto 0) = (MY_WORD_ADDRESS) then
					ddata_r <= x"0000" & axi_x;
				elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + 1) then
					ddata_r <= x"0000" & axi_y;
				elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + 2) then
					ddata_r <= x"0000" & axi_z;
				elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + 3) then
					ddata_r <= x"0000" & s_axi_x_max;
				elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + 4) then
					ddata_r <= x"0000" & s_axi_y_max;
				elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + 5) then
					ddata_r <= x"0000" & s_axi_z_max;
				end if;
			end if;
      end if;
    end if;
  end process;
```
> Os endereço MY_WORD_ADDRESS estão configurados (software/_core/hardware.h) conforme endereço base 18*16=244 (decimal) ou 0x0120 (hexadecimal).
> MY_CHIPSELECT deve ser configurado conforme o valor dos dois bits mais significativos do espaço de memória referente a dados de entrada e saída genéricos definidos em software/_core/hardware.h ("10" -> Input/Output generic address space).

Para generalização do softcore e periféricos foi agregado ao bloco do acelerômetro os sinais que envolvem a manipulação do barramento.

![enter image description here](https://i.imgur.com/STL6NcP.png)

Instanciou-se uma entidade GPIO que receberá os valores de input por meio das chaves SW(7 downto 0) presentes na placa de desenvolvimento utilizada. Os valores de output serão enviados para os LEDs da placa para desenvolvimento da aplicação.
```vhdl
-- Instância GPIO	
generic_gpio: entity work.gpio
        port map(
            clk      => clk,
            rst      => rst,
            daddress => daddress,
            ddata_w  => ddata_w,
            ddata_r  => ddata_r_gpio,
            d_we     => d_we,
            d_rd     => d_rd,
            dcsel    => dcsel,
            dmask    => dmask,
            input    => gpio_input,   -- Conecta com INBUS
            output   => gpio_output,  -- Conecta com OUTBUS
            gpio_interrupts => gpio_interrupts
    );
```
A chave SW(8) foi utilizada como botão de modo debug, que permite enviar os valores do eixo X do acelerômetro para conversão e apresentação nos display de 7 segmentos sem que estes valores passem internamente pelo softcore, possibilitando testes do periférico. A chave SW(9) foi utilizada como botão de reset geral.
```vhdl
  gpio_input(7 downto 0) <= SW(7 downto 0);     -- Conenta entrada do hardware com o GPIO
  LEDR(9 downto 0) <= gpio_output(9 downto 0);  -- Saída do GPIO conectada com os LEDs 
  rst <= SW(9);                                 -- Chave para o RESET
  sw_debug <= SW(8);                            -- Chave para debug
```
Instanciou-se o acelerômetro utilizando como saída a entrada do multiplexador **ddata_r_accelerometer**, cujo endereço será aquele comentado anteriormente (0x0120).
```vhdl    
    -- Instância Acelerômetro
    e_accelerometer: entity work.accel_bus
    generic map(
      MY_CHIPSELECT   => MY_CHIPSELECT, -- "10"
      MY_WORD_ADDRESS => MY_ACCELEROMETER_ADDRESS -- 0x0120
    )
    port map(
      -- core data bus
      daddress => daddress, 
      ddata_w  => ddata_w, 
      ddata_r  => ddata_r_accelerometer, -- Entrada do acelerômetro no MUX
      d_we     => d_we, 
      d_rd     => d_rd, 
      dcsel    => dcsel, 
      dmask    => dmask,
      -- accelerometer spi
      clk      => clk,
      rst      => rst,
      miso     => GSENSOR_SDO,
      sclk     => GSENSOR_SCLK,
      ss_n(0)  => GSENSOR_CS_N,
      mosi     => GSENSOR_SDI,
      -- accelerometer axis
      axi_x    => axi_x, 
      axi_y    => axi_y, 
      axi_z    => axi_z
  );
```
O sinal **sw_debug**, recebido pela chave SW(8), definirá se o display de 7 segmentos receberá o sinal do barramento pelo softcore ou se receberá diretamente do hardware (Debug habilitado), para que seja possível realizar testes no periférico.
```vhdl
    process (sw_debug, axi_x, ddata_r_accelerometer(15 downto 0))
        begin
        if sw_debug = '0' then
      -- debug, so axi x
            axi_disp <= axi_x;
        else
            -- with core, put each axi in interval of delay the code.c
            axi_disp <= ddata_r_accelerometer(15 downto 0);
        end if;
    end process;
```
Os valores dos eixos são finalmente colocados nos displays de 7 segmentos após convertidos por meio do algorítmo **Double dabble** para que apresentem valores decimais no display representados por valores binários. Haverá um ponto no display caso o valor a ser apresentado seja negativo.
```vhdl
--display values of axis by accelerometer in HEX
    disp_data : entity work.disp_data
    port map(   data_in => axi_disp,
                HEX_0 => HEX0,
                HEX_1 => HEX1,
                HEX_2 => HEX2);
```
>Este trecho atualmente está comentado na versão sint_core_yes pois na nova implementação envolvendo os valores máximos o display deve receber os dados do softcore. 

O restante dos displays não utilizados são apagados para que facilite a visualização dos resultados.
```vhdl
HEX3 <= "11111111";
HEX4 <= "11111111";
HEX5 <= "11111111";
```

### Parte 2 - C
Em hardware.h as definição dos endereços utilizados:
```c
#define PERIPH_BASE		((uint32_t)0x4000000) 

#define IONBUS_BASE_ADDRESS 		(*(_IO32 *) (PERIPH_BASE))
#define ACCELEROMETER_BASE_ADDRESS  (*(_IO32 *) (PERIPH_BASE + 18*16*4))
```

#### Protótipos e implementação das funções
Diferentes eixos do acelerômetros e seus valores máximos podem ser lidos por meio de diferentes funções.
```c 
typedef struct
{
	_IO32 axe_x; //	0x0000, 128, x80
	_IO32 axe_y; //	0x0001, 129, x81
	_IO32 axe_z; //	0x0002, 130, x82
	_IO32 axe_x_max; //	0x0000, 131, x83
	_IO32 axe_y_max; //	0x0001, 132, x84
	_IO32 axe_z_max; //	0x0002, 133, x85
	// dado que vai para jose
	// dado que vem do josé
} ACCEL_TYPE;

#define ACCEL ((ACCEL_TYPE *) &ACCELEROMETER_BASE_ADDRESS)

uint32_t read_axe_x(void);
uint32_t read_axe_y(void);
uint32_t read_axe_z(void);
uint32_t read_axe_x_max(void);
uint32_t read_axe_y_max(void);
uint32_t read_axe_z_max(void);
```
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

uint32_t read_axe_x_max(void)
{
	return ACCEL -> axe_x_max;
}

uint32_t read_axe_y_max(void)
{
	return ACCEL -> axe_y_max;
}

uint32_t read_axe_z_max(void)
{
	return ACCEL -> axe_z_max;
}
```

#### Código para testar o funcionamento do periférico
Este código permitirá testar se os valores do acelerômetro estão chegando ao barramento por meio do software.
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

#### Aplicação
A aplicação escolhida foi a de um nível. Os LEDs acenderão conforme o valor do acelerômetro, dando a eles um efeito de "bolha flutuante", assim como ocorre em um nível, indicando a inclinação em planos.

A variável sense indica a sensibilidade com que a "bolha" irá se movimentar. Os valor de INBUS corresponde ao valor das chaves acionadas, que enviamos para *gpio_input* em nosso periférico. 

As primeiras 2 chaves, SW(0) e SW(1), irão definir se o valor utilizado será o do eixo x, y ou z:
- SW(0) -> Eixo X
- SW(1) -> Eixo Y
- SW(0) e SW(1) -> Eixo Z
- Ambas desligadas -> Sempre 0
  
```c
int main(void){
    const int sense = 10; // Sensibility
    uint32_t axe;
    while(1)
    {
        if      (((INBUS&0x3)) == 1){      // axe_x
            axe = read_axe_x();}
        else if (((INBUS&0x3)) == 2){      // axe_y
            axe = read_axe_y();}
        else if (((INBUS&0x3)) == 3){      // axe_z
            axe = read_axe_z();}    
        else{                              // None
            axe = 0;} 	

```

Os valores de *bubble* indicam os LEDs que deverão ser ligados para criar o efeito de bolha.
```c
  uint32_t bubble[19] =  {0x0200, 0x0300, 0x0100, 0x0180,
                          0x0080, 0x00c0, 0x0040, 0x0060,
                          0x0020, 0x0030, 0x0010, 0x0018, 
                          0x0008, 0x000c, 0x0004, 0x0006, 
                          0x0002, 0x0003, 0x0001};
```
Por meio de diversas comparações, o código identifica em quais LEDs devem ser ligados. Os valores do acelerômetro são de 16 bits e podem ser positivos ou negativos.
```c
  // Negative values
  // Must not be higher than FCFF otherwise it will pop up the led on the positive side
  if      (axe > 0xffff -    sense){OUTBUS = bubble[9];}
  else if (axe > 0xffff -  2*sense){OUTBUS = bubble[10];}
  else if (axe > 0xffff -  3*sense){OUTBUS = bubble[11];}
  else if (axe > 0xffff -  4*sense){OUTBUS = bubble[12];}
  else if (axe > 0xffff -  5*sense){OUTBUS = bubble[13];}
  else if (axe > 0xffff -  6*sense){OUTBUS = bubble[14];}
  else if (axe > 0xffff -  7*sense){OUTBUS = bubble[15];}
  else if (axe > 0xffff -  8*sense){OUTBUS = bubble[16];}
  else if (axe > 0xffff -  9*sense){OUTBUS = bubble[17];}
  else if (axe > 0xfcff)           {OUTBUS = bubble[18];}

  // Positive values
  else if (axe > 8*sense){OUTBUS = bubble[0];}
  else if (axe > 7*sense){OUTBUS = bubble[1];}
  else if (axe > 6*sense){OUTBUS = bubble[2];}
  else if (axe > 5*sense){OUTBUS = bubble[3];}
  else if (axe > 4*sense){OUTBUS = bubble[4];}
  else if (axe > 3*sense){OUTBUS = bubble[5];}
  else if (axe > 2*sense){OUTBUS = bubble[6];}
  else if (axe >   sense){OUTBUS = bubble[7];}
  else if (axe >=      0){OUTBUS = bubble[8];}

  else {OUTBUS = 0x0000;}

  // Check if values are working on hardware with fixed value
  // OUTBUS = 0x2ef;
}
return 0;
```

#### Segunda aplicação
Uma segunda aplicação é de um sensor de impacto, para tal o dispositivo armazena o maior valor de leitura de cada um dos eixos em um registrador que é resetado ao se resetar o dispositivo e que pode ser lido acionando a chave SW(3).
```vhdl
process (rst, clk)
  begin
      if rst = '1' then
          s_axi_x_max <= (others => '0');
          s_axi_y_max <= (others => '0');
          s_axi_z_max <= (others => '0');
          
      elsif rising_edge(clk) then
        if axi_x > s_axi_x_max then
          s_axi_x_max <= axi_x;
        end if;

        if axi_y > s_axi_y_max then
          s_axi_y_max <= axi_y;
        end if;

        if axi_z > s_axi_z_max then
          s_axi_z_max <= axi_z;
        end if;

      end if;
  end process;
```

este registrador fica no accel_bus e contel elém do processo de armazenamento que compõe o registrador a seguinte lógica para acesso dos dados pelo softcore:
```vhdl
        elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + 3) then
					ddata_r <= x"0000" & s_axi_x_max;
				end if;
        elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + 4) then
					ddata_r <= x"0000" & s_axi_y_max;
				end if;
        elsif daddress(15 downto 0) = (MY_WORD_ADDRESS + 5) then
					ddata_r <= x"0000" & s_axi_z_max;
				end if;
```
Para a visualização destas informações no display, adicionou-se o seguinte ao arquivo main_accelerometer.c:
```c
        entrada = (INBUS&0X7);
        if      (((entrada)) == 1){      // If SW(0) is on return axe_x values
            axe = read_axe_x();}
        else if (((entrada)) == 2){      // If SW(1) is on return axe_y values
            axe = read_axe_y();}
        else if (((entrada)) == 3){      // If SW(0) and SW(1) is on return axe_z values
            axe = read_axe_z();}
        else if (((entrada)) == 5){      // If SW(2) AND SW(0) is on return axe_x_max values
            axe = read_axe_x_max();}
        else if (((entrada)) == 6){      // If SW(2) and SW(1) is on return axe_y_max values
            axe = read_axe_y_max();}  
        else if (((entrada)) == 7){      // If SW(2) and SW(1) and SW(0) is on return axe_z_max values
            axe = read_axe_z_max();}   
        else{                              // If none of the above, return 0
            axe = 0;}

	SEGMENTS = axe;
```
Observou-se que decorrente de os daados dos eixos serem passados em complemento de 2, valores negativos quando tratados como unsigned são lidos como sendo valores maiores que o maior valor positivo possível, sendo o menor valor negativo o maior valor lido. Logo caso qualquer um dos eixos leia um valor negativo, obersavar-se-há que o valor máximo deste eixo será, errôneamente, um valor extraordináriamente grande. Para tratar tal problema tentou-se a implementação abaixo, porém a mesma não foi bem-sucedida, ficando como proposta de mehoria a solução deste problema.

```c
        signed_axe = (int32_t) axe;
        abs_axe = (uint8_t)((signed_axe < 0) ? -signed_axe : signed_axe);
	SEGMENTS = abs_axe;
```
