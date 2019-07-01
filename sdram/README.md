# Memória SDRAM

Este é um controlador para a memória SDRAM IS42S16320D-7TL.

[Datasheet da SDRAM](http://www.issi.com/WW/pdf/42-45R-S_86400D-16320D-32160D.pdf)

## Como fazer funcionar

Este diretório possui os seguintes arquivos:
* sdram_controller.vhd: Arquivo principal do controlador.
* testbench_sdram.vhd: Arquivo de testbench para o controlador.
* testbench_sdtam.do: Script para simulação no ModelSim.
  
Além destes arquivos, o diretório possui uma pasta `sim/` com modelos comportamental de uma memória SDRAM.

Para utilizar o controlador é apenas necessário adicionar o arquivo sdram_controller.vhd no projeto e instanciá-lo.

## Problemas

* Este controlador consegue ler e escrever na memória SDRAM porém o valor escrita fica na memória por apenas um pequeno período de tempo.