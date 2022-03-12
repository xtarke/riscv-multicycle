# Síntese na FPGA Altera MAX10 DE10-Lite

Já para a síntese na FPGA, devem ser descomentadas as linhas que contenham `delay_(10000)` no arquivo de exemplo [`software/lcd/main_lcd.c`](../../../../software/lcd/main_lcd.c).

O arquivo principal para síntese é o [`de0_lite.vhd`](de0_lite.vhd), em que são utilizados as portas Arduino IO[[2]](#bibliografia), a porta de alimentação de 3,3V ou 5V (de acordo com o modelo do _display_) e a referência no GND, seguindo o mesmo modelo do esquemático abaixo:

<p align="center">
    <img width="100%" height="50%" src="../../connection.png">
</p>

Ao final, após a síntese e gravação do arquivo [`software/lcd/quartus_main_lcd.hex`](../../../../software/lcd/quartus_main_lcd.hex) na memória interna utilizada para o núcleo RISCV, espera-se do exemplo o comportamento demonstrado abaixo:

<p align="center">
    <img width="25%" height="25%" src="../../Nokia5110LCD.gif">
</p>

# Bibliografia
[1] [_Datasheet_ do display Nokia 5110 LCD](https://www.sparkfun.com/datasheets/LCD/Monochrome/Nokia5110.pdf)

[2] [_Datasheet_ da placa de desenvolvimento Altera DE10-Lite](https://www.intel.com/content/dam/www/programmable/us/en/portal/dsn/42/doc-us-dsnbk-42-2912030810549-de10-lite-user-manual.pdf)