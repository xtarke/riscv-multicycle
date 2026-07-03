ifndef RISCV_TOOLS_PREFIX
RISCV_TOOLS_PREFIX = ../../compiler/gcc/bin/riscv-none-elf-
# Para usar no LSC
#RISCV_TOOLS_PREFIX = ~/opt/xPacks/@xpack-dev-tools/riscv-none-embed-gcc/8.3.0-1.1.1/.content/bin/riscv-none-embed-
endif


HARDWARE_NAME = USB-Blaster [1-2]
DEVICE_NAME = @1: 10M50DA(.|ES)/10M50DC (0x031050DD)

QUARTUS_DIR = /opt/intelFPGA/25.1/quartus/bin/
QUARTUS_PROJECT = ../../peripherals/sdram/sint
CXX = $(RISCV_TOOLS_PREFIX)g++ -march=rv32im
CC = $(RISCV_TOOLS_PREFIX)gcc -march=rv32im -O1 -fpack-struct
AS = $(RISCV_TOOLS_PREFIX)gcc -march=rv32im
#CXXFLAGS = -MD -O1 -Wall -std=c++11
#CCFLAGS = -MD -O1 -Wall
#LDFLAGS = -Wl,--gc-sections,--no-relax
LDFLAGS = -Wl
LDLIBS =
MAIN = main_sdram

#test: testbench.vvp $(MAIN)32.hex
#	# vvp -l testbench.log -N testbench.vvp

#testbench.vvp: testbench.v ../../picorv32.v $(MAIN)_dbg.v
#	#iverilog -o testbench.vvp testbench.v ../../picorv32.v
#	#chmod -x testbench.vvp

quartus_$(MAIN).hex: $(MAIN)32.hex
	python3 ../hex8tointel.py $(MAIN).tmp > quartus_$(MAIN).hex
	rm $(MAIN)32.hex

$(MAIN)32.hex: $(MAIN).elf ../hex8tohex32.py
	$(RISCV_TOOLS_PREFIX)objcopy -O verilog $(MAIN).elf $(MAIN).tmp
	$(RISCV_TOOLS_PREFIX)objdump -h -S $(MAIN).elf > "$(MAIN).lss"
	python3 ../hex8tohex32.py $(MAIN).tmp > $(MAIN)32.hex

start.o: ../_core/start.S
	$(CC) -c -nostdlib ../_core/start.S $(LDLIBS)

$(MAIN).elf: $(MAIN).o start.o ../_core/syscalls.o ../_core/utils.o 
	$(CC) $(LDFLAGS),-Map=$(MAIN).map -o $@ $^ -T ../_core/sections.ld $(LDLIBS)
	chmod -x $(MAIN).elf

sint:
	$(QUARTUS_DIR)quartus_sh --flow compile $(QUARTUS_PROJECT)/de10_lite

fpga: sint
	$(QUARTUS_DIR)quartus_pgm -z -m JTAG -o "p;$(QUARTUS_PROJECT)/output_files/de10_lite.sof"

flash: quartus_$(MAIN).hex fpga
	@echo 'begin_memory_edit -hardware_name {$(HARDWARE_NAME)} -device_name {$(DEVICE_NAME)}' > /tmp/_flash_vga.tcl
	@echo 'update_content_to_memory_from_file -instance_index 0 -mem_file_path {$(CURDIR)/quartus_$(MAIN).hex} -mem_file_type {hex}' >> /tmp/_flash_vga.tcl
	@echo 'end_memory_edit' >> /tmp/_flash_vga.tcl
	$(QUARTUS_DIR)quartus_stp_tcl -t /tmp/_flash_vga.tcl

clean:
	rm -f ../*/*.o *.o *.d *.tmp start.elf *.lss *.map
	rm -f $(MAIN).elf $(MAIN).hex $(MAIN)32.hex quartus_$(MAIN).hex

-include *.d
.PHONY: test clean
