ifndef RISCV_TOOLS_PREFIX
RISCV_TOOLS_PREFIX = C:/Workspace_ProjetoFinal_DLP/riscv-multicycle-master/compiler/gcc/bin/riscv-none-embed-
#RISCV_TOOLS_PREFIX = riscv-multicycle-master
#RISCV_TOOLS_PREFIX =C:PROJETO_FINAL\riscv-multicycle-master\compiler\gcc
#RISCV_TOOLS_PREFIX = C:PROJETO_FINAL\riscv-multicycle-master


endif


QUARTUS_DIR=~/Data/Apps/intelFPGA/20.1/quartus/bin/
CXX = $(RISCV_TOOLS_PREFIX)g++ -march=rv32im
CC = $(RISCV_TOOLS_PREFIX)gcc -march=rv32im -O1 -fpack-struct
AS = $(RISCV_TOOLS_PREFIX)gcc -march=rv32im
#CXXFLAGS = -MD -O1 -Wall -std=c++11
#CCFLAGS = -MD -O1 -Wall
#LDFLAGS = -Wl,--gc-sections,--no-relax
LDFLAGS = -Wl
LDLIBS =
MAIN = simple_serial_transmitter

quartus_$(MAIN).hex: $(MAIN)32.hex
	python3 ../hex8tointel.py $(MAIN).tmp > quartus_$(MAIN).hex
	del $(MAIN)32.hex

$(MAIN)32.hex: $(MAIN).elf ../hex8tohex32.py
	$(RISCV_TOOLS_PREFIX)objcopy -O verilog $(MAIN).elf $(MAIN).tmp
	$(RISCV_TOOLS_PREFIX)objdump -h -S $(MAIN).elf > "$(MAIN).lss"
	python3 ../hex8tohex32.py $(MAIN).tmp > $(MAIN)32.hex
	
	

start.o: ../_core/start.S
	$(CC) -c -nostdlib ../_core/start.S $(LDLIBS)

$(MAIN).elf: $(MAIN).o start.o ../_core/syscalls.o ../_core/utils.o ../gpio/gpio.o simple_serial_transmitter.o
	$(CC) $(LDFLAGS),-Map=$(MAIN).map -o $@ $^ -T ../_core/sections.ld $(LDLIBS)

sint:
	$(QUARTUS_DIR)quartus_sh --flow compile ../../peripherals/gpio/sint/de10_lite/de10_lite.cdf

fpga:
	$(QUARTUS_DIR)quartus_pgm -z -m JTAG -o "p;../../peripherals/gpio/sint/de10_lite/output_files/de10_lite.sof"

flash: quartus_$(MAIN).hex
	$(QUARTUS_DIR)quartus_stp_tcl -t "flash.tcl"

clean:
	del /f /q $(MAIN).elf $(MAIN).hex $(MAIN)32.hex quartus_$(MAIN).hex 2>nul
	del /f $(MAIN).elf $(MAIN).hex $(MAIN)32.hex quartus_$(MAIN).hex

-include *.d
.PHONY: test clean