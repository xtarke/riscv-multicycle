RISCV_TOOLS_PREFIX = ../../compiler/gcc/bin/riscv-none-elf-

QUARTUS_DIR=~/Data/Apps/intelFPGA/20.1/quartus/bin/
CXX = $(RISCV_TOOLS_PREFIX)g++ -march=rv32im
CC = $(RISCV_TOOLS_PREFIX)gcc -march=rv32im -O1 -fpack-struct
AS = $(RISCV_TOOLS_PREFIX)gcc -march=rv32im
LDFLAGS = -Wl
LDLIBS =
MAIN = main

.PHONY: all clean sint fpga flash

# Default target builds the ELF and the .hex for Quartus
all: $(MAIN).elf quartus_$(MAIN).hex

quartus_$(MAIN).hex: $(MAIN)32.hex
	python $(CURDIR)/../hex8tointel.py $(MAIN).tmp > quartus_$(MAIN).hex
	rm $(MAIN)32.hex

$(MAIN)32.hex: $(MAIN).elf ../hex8tohex32.py
	$(RISCV_TOOLS_PREFIX)objcopy -O verilog $(MAIN).elf $(MAIN).tmp
	$(RISCV_TOOLS_PREFIX)objdump -h -S $(MAIN).elf > "$(MAIN).lss"
	python ../hex8tohex32.py $(MAIN).tmp > $(MAIN)32.hex

start.o: ../_core/start.S
	$(CC) -c -nostdlib ../_core/start.S $(LDLIBS)

syscalls.o: ../_core/syscalls.c
	$(CC) -c ../_core/syscalls.c

utils.o: ../_core/utils.c
	$(CC) -c ../_core/utils.c

main.o: $(MAIN).c
	$(CC) -c $(MAIN).c -o $@

gpio.o: ../gpio/gpio.c
	$(CC) -c ../gpio/gpio.c

$(MAIN).elf: $(MAIN).o start.o syscalls.o utils.o gpio.o
	$(CC) $(LDFLAGS),-Map=$(MAIN).map -o $@ $^ -T ../_core/sections.ld $(LDLIBS)
	chmod -x $(MAIN).elf

sint:
	$(QUARTUS_DIR)quartus_sh --flow compile ../../peripherals/as5600_pwm/sint/de10_lite/de10_lite.cdf

fpga:
	$(QUARTUS_DIR)quartus_pgm -z -m JTAG -o "p;../../peripherals/as5600_pwm/sint/de10_lite/output_files/de10_lite.sof"

flash: quartus_$(MAIN).hex
	$(QUARTUS_DIR)quartus_stp_tcl -t "../flash.tcl"

clean:
	rm -f *.o *.d *.tmp *.elf *.lss *.map *.hex

-include *.d

.PHONY: test clean sint fpga flash
