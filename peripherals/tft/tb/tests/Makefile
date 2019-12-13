ifndef RISCV_TOOLS_PREFIX
RISCV_TOOLS_PREFIX = riscv32-unknown-elf-
# Para usar no LSC
RISCV_TOOLS_PREFIX = $(HOME)/opt/xPacks/@gnu-mcu-eclipse/riscv-none-gcc/8.2.0-2.2.1/.content/bin/riscv-none-embed-
endif
QUARTUS_DIR= $(HOME)/intelFPGA_lite/18.1/quartus/bin
CXX = $(RISCV_TOOLS_PREFIX)g++ -march=rv32im
CC = $(RISCV_TOOLS_PREFIX)gcc -march=rv32im -O1 -fpack-struct
AS = $(RISCV_TOOLS_PREFIX)gcc -march=rv32im
#CXXFLAGS = -MD -O1 -Wall -std=c++11
#CCFLAGS = -MD -O1 -Wall 
#LDFLAGS = -Wl,--gc-sections,--no-relax
LDFLAGS = -Wl
LDLIBS =
MAIN = main_tft

#test: testbench.vvp $(MAIN)32.hex
#	# vvp -l testbench.log -N testbench.vvp

#testbench.vvp: testbench.v ../../picorv32.v $(MAIN)_dbg.v
#	#iverilog -o testbench.vvp testbench.v ../../picorv32.v
#	#chmod -x testbench.vvp

$(MAIN)32.hex: $(MAIN).elf hex8tohex32.py
	$(RISCV_TOOLS_PREFIX)objcopy -O verilog $(MAIN).elf $(MAIN).tmp
	$(RISCV_TOOLS_PREFIX)objdump -h -S $(MAIN).elf > "$(MAIN).lss"
	python3 hex8tohex32.py $(MAIN).tmp > $(MAIN)32.hex
	python3 hex8tointel.py $(MAIN).tmp > quartus_$(MAIN).hex
	python3 hex8tointel.py $(MAIN).tmp > quartus.hex

#$(MAIN)_dbg.v: $(MAIN).map
#	python3 map2debug.py

start.o: start.S
	$(CC) -c -nostdlib start.S $(LDLIBS)

$(MAIN).elf: $(MAIN).o syscalls.o start.o utils.o tft.o
	$(CC) $(LDFLAGS),-Map=$(MAIN).map -o $@ $^ -T sections.ld $(LDLIBS)
	chmod -x $(MAIN).elf

sint:
	$(QUARTUS_DIR)quartus_sh --flow compile ../../sint/core/de10_lite/de0_lite.cdf
	
fpga:
	$(QUARTUS_DIR)quartus_pgm -z -m JTAG -o "p;../../sint/core/de10_lite/de0_lite.sof"

clean:
	rm -f *.o *.d *.tmp start.elf
	rm -f $(MAIN).elf $(MAIN).hex $(MAIN)32.hex
	#rm -f testbench.vvp testbench.vcd

-include *.d
.PHONY: test clean
