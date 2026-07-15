RISCV_TOOLS_PREFIX = ../../compiler/gcc/bin/riscv-none-elf-

QUARTUS_DIR = /opt/intelFPGA/25.1/quartus/bin/
QUARTUS_PROJECT = ../../peripherals/vga/sint
CXX = $(RISCV_TOOLS_PREFIX)g++ -march=rv32im
CC = $(RISCV_TOOLS_PREFIX)gcc -march=rv32im -O1 -fpack-struct
AS = $(RISCV_TOOLS_PREFIX)gcc -march=rv32im
LDFLAGS = -Wl
LDLIBS =
MAIN = main_vga

# Auto-detect the USB-Blaster cable name (its [1-x] index changes with USB
CABLE = $(shell $(QUARTUS_DIR)jtagconfig 2>/dev/null | grep -oE 'USB-Blaster \[[0-9-]+\]' | head -1)
DEVICE_NAME = @1: 10M50DA(.|ES)/10M50DC (0x031050DD)

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

fpga:
	$(QUARTUS_DIR)quartus_pgm -c "$(CABLE)" -m jtag -o "p;$(QUARTUS_PROJECT)/output_files/de10_lite.sof@1"

flash: quartus_$(MAIN).hex fpga
	@echo 'begin_memory_edit -hardware_name {$(CABLE)} -device_name {$(DEVICE_NAME)}' > /tmp/_flash_vga.tcl
	@echo 'update_content_to_memory_from_file -instance_index 0 -mem_file_path {$(CURDIR)/quartus_$(MAIN).hex} -mem_file_type {hex}' >> /tmp/_flash_vga.tcl
	@echo 'end_memory_edit' >> /tmp/_flash_vga.tcl
	$(QUARTUS_DIR)quartus_stp_tcl -t /tmp/_flash_vga.tcl

clean:
	rm -f ../*/*.o *.o *.d *.tmp start.elf *.lss *.map
	rm -f $(MAIN).elf $(MAIN).hex $(MAIN)32.hex quartus_$(MAIN).hex

-include *.d
.PHONY: sint fpga flash clean
