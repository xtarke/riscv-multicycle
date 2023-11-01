# RISC SoftCore

[![pt-br](https://img.shields.io/badge/lang-pt--br-green.svg)](./README.md)

RISC SoftCore is a dyadic-purpose VHDL implementation of the RISCV RV32IM instruction set. This particular version does not implement a pipeline. The idea is to create a microcontroller with common peripherals such as I2C, USART, SPI and GPIOs initially used for the discipline of Programmable Logic Devices.

Programming/compiler tools can be obtained from this [link](https://github.com/xpack-dev-tools/riscv-none-embed-gcc-xpack/releases).

Check in-depth architecture here:  [Virgularor, a minimum RISC-V](http://tice.sea.eseo.fr/riscv/)

Check [here](https://github.com/TheThirdOne/rars) a assembly simulator based on Mars

![Core diagram](./readme_img/core.svg)

## Getting Started (hardware):

- Simulation:
    - Run this script [testbench.do](./testbench.do) in Modelsim (Altera Edition).
    - Main testbench: [testbench.vhd](./testbench.vhd).Simulates the core, a timer and general purpose pins (gpio and 7-segment display).
    - Check that the program file is pointed correctly  (i.e.: __./software/quartus_blink.hex__) in module [iram_quartus.vhdl](./memory/iram_quartus.vhd).
    - See this [complete diagram](./readme_img/testbench.svg)

- Synthesis: Quartus 19.1 or higher (tested in the DE10- Lite development Kit)
    - Open the generic project at [./peripherals/gpio/sint/de10_lite/](./peripherals/gpio/sint/de10_lite/)
    - For post-synthesis software programming :
        - Quartus Main Menu: Tools -> In-System Memory Editor

## Getting Started (software):

Compilation requires the _toolchain_ __riscv-none-elf__ (or __riscv-none-embed__) supporting the subset __RV32IM__, __without ABI__. At ./software/ folder, there are several examples. Note that in the current phase of the project we use a custom _linker_ _script_ (sections.ld). _libc_ has not yet been tested/supported.

See [here](./compiler/README-en.md) more information in order to install gcc compiler.