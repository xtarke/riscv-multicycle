ifndef RISCV_TOOLS_PREFIX
#RISCV_TOOLS_PREFIX = riscv32-unknown-elf-
# Para usar no LSC
RISCV_TOOLS_PREFIX = ~/opt/xPacks/@xpack-dev-tools/riscv-none-embed-gcc/8.3.0-1.1.1/.content/bin/riscv-none-embed-
endif
QUARTUS_DIR=/opt/altera/18.1/quartus/bin/
CXX = $(RISCV_TOOLS_PREFIX)g++ -march=rv32im
CC = $(RISCV_TOOLS_PREFIX)gcc -march=rv32im -O1 -fpack-struct
AS = $(RISCV_TOOLS_PREFIX)gcc -march=rv32im
#CXXFLAGS = -MD -O1 -Wall -std=c++11
#CCFLAGS = -MD -O1 -Wall 
#LDFLAGS = -Wl,--gc-sections,--no-relax
LDFLAGS = -Wl,--gc-sections
LDLIBS =

#test: testbench.vvp firmware32.hex
#	# vvp -l testbench.log -N testbench.vvp

#testbench.vvp: testbench.v ../../picorv32.v firmware_dbg.v
#	#iverilog -o testbench.vvp testbench.v ../../picorv32.v
#	#chmod -x testbench.vvp

firmware32.hex: firmware.elf hex8tohex32.py
	$(RISCV_TOOLS_PREFIX)objcopy -O verilog firmware.elf firmware.tmp
	$(RISCV_TOOLS_PREFIX)objdump -h -S firmware.elf > "firmware.lss"
	python3 hex8tohex32.py firmware.tmp > firmware32.hex
	python3 hex8tointel.py firmware.tmp > quartus.hex

#firmware_dbg.v: firmware.map
#	python3 map2debug.py

start.o: start.S
	$(CC) -c -nostdlib start.S $(LDLIBS)

firmware.elf: firmware.o syscalls.o start.o utils.o
	$(CC) $(LDFLAGS),-Map=firmware.map -o $@ $^ -T sections.ld $(LDLIBS)
	chmod -x firmware.elf

sint:
	$(QUARTUS_DIR)quartus_sh --flow compile ../sint/de10_lite/de0_lite.cdf
	
fpga:
	$(QUARTUS_DIR)quartus_pgm -z -m JTAG -o "p;../sint/de10_lite/de0_lite.sof"

clean:
	rm -f *.o *.d *.tmp start.elf
	rm -f firmware.elf firmware.hex firmware32.hex
	#rm -f testbench.vvp testbench.vcd

-include *.d
.PHONY: test clean
 
