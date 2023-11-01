# RISC SoftCore

[![en](https://img.shields.io/badge/lang-en-red.svg)](./README-en.md)

RISC SoftCore é uma implementação em VHDL com fins diádicos do conjunto de instruções RISCV RV32IM. Essa versão particular não implementa um pipeline. A ideia é criar um microcontrolador com periféricos comuns como I2C, USART, SPI e GPIOs inicialmente utilizado para disciplina de Dispositivos Lógicos Programáveis.

Ferramentas de programação podem ser obtidas no [Compliler](https://github.com/xpack-dev-tools/riscv-none-embed-gcc-xpack/releases).

Animação do funcionamento da arquitetura em [Virgularor: minimum RISC-V](http://tice.sea.eseo.fr/riscv/)

Simulador assembly baseado no MARS: [RARS](https://github.com/TheThirdOne/rars)

![Diagrama Núcleo](./readme_img/core.svg)

## Getting Started (hardware):

- Simulação:
    - Execute o script script [testbench.do](./testbench.do) no Modelsim (Altera Edition).
    - Testbench principal: [testbench.vhd](./testbench.vhd). Simula o núcleo, um timer e pinos de propósito geral (gpio e display de 7 segmentos).
    - Verifique se o arquivo de programa está apontado corretamente (i.e.: __./software/quartus_blink.hex__) no módulo [iram_quartus.vhdl](./memory/iram_quartus.vhd).
    - Veja esse [diagrama completo do testbench](./readme_img/testbench.svg)

- Síntese: Quartus 19.1 ou superior (testado no Kit de desenvolvimento DE10-Lite)
    - Abra o projeto genérico em [./peripherals/gpio/sint/de10_lite/](./peripherals/gpio/sint/de10_lite/)
    - Para gravação do programa pós síntese:
        - Menu principal do Quartus: Tools -> In-System Memory Editor

## Getting Started (software):

A compilação de programas necessita do _toolchain_ __riscv-none-elf__ (ou __riscv-none-embed__) suportando o subconjunto __RV32IM__, __sem ABI__. Em ./software/ há vários exemplos. Perceba que na fase atual do projeto utilizamos um _script_ de _linker_ customizado (sections.ld). _libc_ ainda não foi testado/suportado.

Veja mais detalhes para a instalação compilador [aqui](./compiler/README.md)


