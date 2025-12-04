# RISC SoftCore

[![pt-br](https://img.shields.io/badge/lang-pt--br-green.svg)](./README.md)

> **Viewing Tip:** For better reading of this Markdown document, you can:
> - In VS Code/Editor: Press `Ctrl+Shift+V` to open preview
> - Online: Use [GitHub](https://github.com) or [MarkdownLivePreview](https://markdownlivepreview.com/) for formatted visualization

RISC SoftCore is a dyadic-purpose VHDL implementation of the RISCV RV32IM instruction set. This particular version does not implement a pipeline. The idea is to create a microcontroller with common peripherals such as I2C, USART, SPI and GPIOs initially used for the discipline of Programmable Logic Devices.

Programming/compiler tools can be obtained from this [link](https://github.com/xpack-dev-tools/riscv-none-embed-gcc-xpack/releases).

Check in-depth architecture here:  [Virgularor, a minimum RISC-V](http://tice.sea.eseo.fr/riscv/)

Check [here](https://github.com/TheThirdOne/rars) a assembly simulator based on Mars

![Core diagram](./readme_img/core.svg)

## System Requirements

### Hardware
- DE10-Lite FPGA board (Intel/Altera MAX 10) or compatible
- USB Blaster cable for programming and debugging
- Computer with at least 4GB RAM

### Software
- **Simulation:** ModelSim-Altera Edition 20.1 or higher
- **Synthesis:** Quartus Prime Lite 19.1 or higher
- **Compilation:** RISC-V Toolchain (riscv-none-elf-gcc or riscv-none-embed-gcc)
  - Support for RV32IM
  - Without ABI (bare-metal)

## Getting Started

### 1. Simulation with ModelSim

Simulation allows testing the core and peripherals before synthesis.

**Step 1:** Open ModelSim-Altera Edition

**Step 2:** Configure directory variables in terminal

**Important:** Execute the commands below in bash/shell terminal.

```bash
# Directory variables - ADJUST THE PATH BELOW
# Put here the complete path where you cloned/extracted the project
PROJECT_DIR="/complete/path/to/riscv-multicycle"

# Example on Linux:
# PROJECT_DIR="/home/your_user/projects/riscv-multicycle"
# PROJECT_DIR="$HOME/Documents/riscv-multicycle"

# Example on Windows (Git Bash/WSL):
# PROJECT_DIR="/c/Users/your_user/projects/riscv-multicycle"
# PROJECT_DIR="/mnt/c/Users/your_user/projects/riscv-multicycle"

# Define derived variables (DO NOT CHANGE THESE)
SOFTWARE_DIR="$PROJECT_DIR/software"
MEMORY_DIR="$PROJECT_DIR/memory"

# Navigate to project directory
cd "$PROJECT_DIR"
```

**Step 3:** Run the simulation script
```tcl
do testbench.do
```

**Step 4:** Verify the program file
```bash
# Edit the memory file to point to your program
vim "$MEMORY_DIR/iram_quartus.vhd"
# or
gedit "$MEMORY_DIR/iram_quartus.vhd"
```
- Locate the line that loads the `.hex` file
- Point to the desired program:
```vhdl
-- Example configuration in iram_quartus.vhd:
file_name := "$SOFTWARE_DIR/quartus_blink.hex";
```

**Step 5:** Run the simulation
- In ModelSim, click "Run" or execute: `run -all`
- Observe the waveforms of the signals

**Simulated components:**
- RISC-V RV32IM core
- Peripheral timer
- GPIO (general purpose I/O)
- 7-segment display

**Complete diagram:** [testbench.svg](./readme_img/testbench.svg)

**Troubleshooting:**
- **Compilation error:** Check if all .vhd files are in the project
- **.hex file not found:** Use correct absolute or relative path
- **Simulation does not start:** Check ModelSim version (requires Altera Edition)

---

### 2. Synthesis with Quartus Prime

Synthesis generates the bitstream for FPGA programming.

**Step 1:** Open Quartus Prime Lite Edition

**Step 2:** Open the example project

**In terminal**, execute:

```bash
# Variables for synthesis (make sure PROJECT_DIR is defined)
QUARTUS_PROJECT="$PROJECT_DIR/peripherals/gpio/sint/de10_lite"
PROJECT_FILE="$QUARTUS_PROJECT/de10_lite.qpf"

# Open project in Quartus via command line
quartus "$PROJECT_FILE" &

# OR navigate manually in terminal:
cd "$QUARTUS_PROJECT"
# Then open Quartus through the GUI
```
- Open the `.qpf` file (Quartus Project File) in Quartus Prime

**Step 3:** Configure the device
- Verify the device is set to `10M50DAF484C7G` (DE10-Lite)
- Menu: Assignments -> Device

**Step 4:** Compile the project
- Menu: Processing -> Start Compilation
- Or press `Ctrl+L`
- Wait for compilation (may take several minutes)

**Step 5:** Program the FPGA
- Connect the DE10-Lite board via USB
- Menu: Tools -> Programmer
- Select the generated `.sof` file
- Click "Start" to program

**Step 6:** Program memory post-synthesis
- Menu: Tools -> In-System Memory Editor
- Connect to the FPGA
- Load the `.hex` file of your program
- Write to instruction memory

**Typical resource usage:**
- Logic Elements: ~3000-4000 LEs
- Memory bits: ~100Kb
- Maximum frequency: ~50 MHz

**Troubleshooting:**
- **Timing error:** Reduce clock frequency or optimize code
- **FPGA not detected:** Check USB Blaster drivers
- **Pin error:** Verify constraints file (.qsf)

---

### 3. Software Compilation

Create C/Assembly programs for the RISC-V core.

**Toolchain Requirements:**
- Compiler: `riscv-none-elf-gcc` or `riscv-none-embed-gcc`
- Architecture: RV32IM (32-bit with multiplication/division)
- ABI: Bare-metal (no operating system)
- Recommended version: GCC 10.2.0 or higher

**Toolchain Installation:**

See the complete installation guide at [compiler/README-en.md](./compiler/README-en.md)

**Download:**
- [RISC-V GNU Toolchain Releases](https://github.com/xpack-dev-tools/riscv-none-embed-gcc-xpack/releases)

**Verify installation:**
```bash
riscv-none-elf-gcc --version
```

**Step 1:** Configure variables and navigate to examples folder

**In terminal**, execute:

```bash
# Directory variables - ADJUST THE PATH BELOW
# Put here the complete path where you cloned/extracted the project
PROJECT_DIR="/complete/path/to/riscv-multicycle"

# Define derived variable
SOFTWARE_DIR="$PROJECT_DIR/software"

# Navigate to software folder
cd "$SOFTWARE_DIR"
```

**Step 2:** Choose an example
```bash
# Available examples:
ls -l "$SOFTWARE_DIR"

# blink.c        - LED blink (basic example)
# gpio/          - GPIO pin control
# uart/          - Serial communication
# timer/         - Timer usage
# spi/           - SPI communication
# i2c/           - I2C communication
# modbus/        - Modbus RTU protocol
```

**Step 3:** Compile the program
```bash
# For the main example (blink)
cd "$SOFTWARE_DIR"
make clean
make

# For a specific peripheral (example: UART)
cd "$SOFTWARE_DIR/uart"
make clean
make
```

**Step 4:** Check generated files
- `program.elf` - Executable file
- `program.hex` - Programming file (Intel HEX format)
- `program.lst` - Listing with assembly and addresses

**Project Structure:**
- `sections.ld` - Custom linker script (defines memory layout)
- `Makefile` - Build automation
- `*.c` - C source code
- `*.S` - Assembly code

**Memory Map:**
```
0x00000000 - 0x00003FFF : Instruction RAM (16KB)
0x00004000 - 0x00007FFF : Data RAM (16KB)
0x80000000 - 0x8FFFFFFF : Memory-mapped peripherals
```

**Important notes:**
- Standard `libc` is not yet supported
- Use bare-metal functions for I/O
- Custom linker script is mandatory
- Interrupts must be configured manually

**Troubleshooting:**
- **Command not found:** Add toolchain to PATH
- **Linking error:** Check `sections.ld` file
- **Program does not execute:** Verify memory map
- **Code too large:** Optimize with `-Os` or reduce features

---

## Usage Examples

**Note:** Execute all commands below in bash/shell terminal.

### Example 1: Blink LED
```bash
# Define directory variables (adjust the path)
# Put here the path where you saved the project
PROJECT_DIR="/complete/path/to/riscv-multicycle"
SOFTWARE_DIR="$PROJECT_DIR/software"

cd "$SOFTWARE_DIR"
make clean
make

# Check generated file:
ls -lh "$SOFTWARE_DIR/quartus_blink.hex"
```

### Example 2: UART Communication
```bash
UART_DIR="$SOFTWARE_DIR/uart"

cd "$UART_DIR"
# Configure baudrate in code before compiling
vim "$UART_DIR/main.c"  # or your preferred editor

make clean
make

# Generated file:
ls -lh "$UART_DIR/"*.hex
```

### Example 3: Modbus RTU Peripheral
```bash
MODBUS_DIR="$PROJECT_DIR/peripherals/modbus"

cd "$MODBUS_DIR"

# See complete documentation:
cat "$MODBUS_DIR/README.md"
# or open in browser:
xdg-open "$MODBUS_DIR/README.md"

# Simulate with ModelSim:
cd "$PROJECT_DIR"
vsim -do "$MODBUS_DIR/tb_modbus.do"
```

---

## Additional Resources

- **Assembly Simulator:** [RARS - RISC-V Assembler and Runtime Simulator](https://github.com/TheThirdOne/rars)
- **Architecture Animation:** [Virgularor: minimum RISC-V](http://tice.sea.eseo.fr/riscv/)
- **RISC-V Specification:** [riscv.org/specifications](https://riscv.org/technical/specifications/)