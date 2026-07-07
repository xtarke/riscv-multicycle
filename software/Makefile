RISCV_TOOLS_PREFIX = C:/PRG/Atividades/riscv-multicycle/compiler/gcc/bin/riscv-none-embed-

QUARTUS_DIR = C:/intelFPGA/19.1/quartus/bin/

PYTHON = python

CXX = $(RISCV_TOOLS_PREFIX)g++ -march=rv32im
CC  = $(RISCV_TOOLS_PREFIX)gcc -march=rv32im -O1 -fpack-struct
AS  = $(RISCV_TOOLS_PREFIX)gcc -march=rv32im

LDFLAGS = -Wl
LDLIBS =

MAIN = blink

quartus_$(MAIN).hex: $(MAIN)32.hex
	$(PYTHON) hex8tointel.py $(MAIN).tmp > quartus_$(MAIN).hex
	rm -f $(MAIN)32.hex

$(MAIN)32.hex: $(MAIN).elf hex8tohex32.py
	$(RISCV_TOOLS_PREFIX)objcopy -O verilog $(MAIN).elf $(MAIN).tmp
	$(RISCV_TOOLS_PREFIX)objdump -h -S $(MAIN).elf > "$(MAIN).lss"
	$(PYTHON) hex8tohex32.py $(MAIN).tmp > $(MAIN)32.hex

start.o: _core/start.S
	$(CC) -c -nostdlib _core/start.S $(LDLIBS)

_core/syscalls.o: _core/syscalls.c
	$(CC) -c -nostdlib _core/syscalls.c -o _core/syscalls.o $(LDLIBS)

_core/utils.o: _core/utils.c
	$(CC) -c -nostdlib _core/utils.c -o _core/utils.o $(LDLIBS)

gpio/gpio.o: gpio/gpio.c
	$(CC) -c -nostdlib gpio/gpio.c -o gpio/gpio.o $(LDLIBS)

$(MAIN).o: $(MAIN).c
	$(CC) -c -nostdlib $(MAIN).c -o $(MAIN).o $(LDLIBS)

$(MAIN).elf: $(MAIN).o start.o _core/syscalls.o _core/utils.o gpio/gpio.o
	$(CC) $(LDFLAGS),-Map=$(MAIN).map -o $@ $^ -T _core/sections.ld $(LDLIBS)
	chmod -x $(MAIN).elf

sint:
	$(QUARTUS_DIR)quartus_sh --flow compile ../peripherals/gpio/sint/de10_lite/de10_lite.cdf

fpga:
	$(QUARTUS_DIR)quartus_pgm -z -m JTAG -o "p;../peripherals/gpio/sint/de10_lite/output_files/de10_lite.sof"

flash: quartus_$(MAIN).hex
	$(QUARTUS_DIR)quartus_stp_tcl -t "flash.tcl"

clean:
	rm -f */*.o
	rm -f *.o
	rm -f *.d
	rm -f *.tmp
	rm -f *.lss
	rm -f *.map
	rm -f start.elf
	rm -f $(MAIN).elf
	rm -f $(MAIN).hex
	rm -f $(MAIN)32.hex
	rm -f quartus_$(MAIN).hex

-include *.d

.PHONY: sint fpga flash clean