ifndef RISCV_TOOLS_PREFIX
#RISCV_TOOLS_PREFIX=riscv-none-embed-
# Para usar no LSC
RISCV_TOOLS_PREFIX=/home/gustavo/opt/xPacks/@gnu-mcu-eclipse/riscv-none-gcc/8.2.0-2.2.1/.content/bin/riscv-none-embed-
endif
QUARTUS_DIR=/mnt/c/intelFPGA_lite/20.1/quartus/bin64/
CXX = $(RISCV_TOOLS_PREFIX)g++ -march=rv32im
CC = $(RISCV_TOOLS_PREFIX)gcc -march=rv32im -O1 -fpack-struct
AS = $(RISCV_TOOLS_PREFIX)gcc -march=rv32im
#CXXFLAGS = -MD -O1 -Wall -std=c++11
#CCFLAGS = -MD -O1 -Wall
#LDFLAGS = -Wl,--gc-sections,--no-relax
LDFLAGS = -Wl
LDLIBS =
MAIN = lcd

#test: testbench.vvp $(MAIN)32.hex
#	# vvp -l testbench.log -N testbench.vvp

#testbench.vvp: testbench.v ../../picorv32.v $(MAIN)_dbg.v
#	#iverilog -o testbench.vvp testbench.v ../../picorv32.v
#	#chmod -x testbench.vvp

quartus_$(MAIN).hex: $(MAIN)32.hex
	python3 hex8tointel.py $(MAIN).tmp > quartus_$(MAIN).hex
	rm $(MAIN)32.hex

$(MAIN)32.hex: $(MAIN).elf hex8tohex32.py
	$(RISCV_TOOLS_PREFIX)objcopy -O verilog $(MAIN).elf $(MAIN).tmp
	$(RISCV_TOOLS_PREFIX)objdump -h -S $(MAIN).elf > "$(MAIN).lss"
	python3 hex8tohex32.py $(MAIN).tmp > $(MAIN)32.hex

start.o: start.S
	$(CC) -c -nostdlib start.S $(LDLIBS)

$(MAIN).elf: $(MAIN).o syscalls.o start.o utils.o
	$(CC) $(LDFLAGS),-Map=$(MAIN).map -o $@ $^ -T sections.ld $(LDLIBS)
	chmod -x $(MAIN).elf

sint:
	$(QUARTUS_DIR)quartus_sh.exe --flow compile ../../peripherals/lcd/sint/de10_lite/de10_lite.cdf

fpga:
	$(QUARTUS_DIR)quartus_pgm.exe -z -m JTAG -o "p;/mnt/c/Users/Home/Documents/Gustavo/PLD/riscv-multicycle-master/peripherals/lcd/sint/de10_lite/output_files/de10_lite.sof"

flash:
	$(QUARTUS_DIR)quartus_stp_tcl.exe -t "flash.tcl"

clean:
	#!/bin/bash <<<<<<< HEAD
	rm -f *.o *.d *.tmp start.elf *.lss *.map
	#!/bin/bash =======
	rm -f *.o *.d *.tmp start.elf
	#!/bin/bash >>>>>>> cb5b91ddc8a8f1db590880c74afc8d74e09835e9
	rm -f $(MAIN).elf $(MAIN).hex $(MAIN)32.hex quartus_$(MAIN).hex

	
-include *.d
.PHONY: test clean
