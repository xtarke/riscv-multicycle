# RISC SoftCore
---

RISC SoftCore é uma implementação em VHDL com fins diádicos do conjunto de instruções RISCV RV32I. Essa versão particular não implementa um pipeline. A ideia é criar um microcontrolador com periféricos comuns como I2C, USART, SPI e GPIOs inicialmente utilizado para disciplina de Dispositivos Lógicos Programáveis.

Ferramentas de programação podem ser obtidas no [RISC-V Website](https://riscv.org/software-status/).

## Getting Started (hardware):

- Simulação:
    - ModelSim: execução do script testbench.do
    - testbench: ./core/testbench.vhd
    - Utilizar uma memória SRAM IP (32-bits x 1024 words Quartus RAM (dual port: portA -> riscV, portB -> In-System Mem Editor)

- Síntese: Quartus 15 ou superior (testado no Kit de desenvolvimento DE10-Lite)
    - Projeto: utilize ./sint/de10_lite
    - Para gravação do programa pós síntese:
        - Utilizar uma memória SRAM IP (32-bits x 1024 words Quartus RAM (dual port: portA -> riscV, portB -> In-System Mem Editor)
        - Gravação pelo In-System Memory Editor
    - Utilize uma PLL para ajuste do clock


## Getting Started (software):

A compilação de programas necessita do _toolchain_ __riscv32-unknown-elf__ suportando o subconjunto RV32I. Em ./tests/ há um exemplo bem simples de Makefile. Perceba que na fase atual do projeto utilizamos um _script_ de _linker_ customizado (sections.ld). libc ainda não é testado suportado.

Após a compilação, mova, copie ou faça um _link_ simbólico de ./tests/quartus.hex para a raiz do projeto.



