ifndef RISCV_TOOLS_PREFIX
RISCV_TOOLS_PREFIX = ../../compiler/gcc/bin/riscv-none-elf-
endif

QUARTUS_DIR = ~/intelFPGA/quartus21.1/21.1/quartus/bin/
CXX = $(RISCV_TOOLS_PREFIX)g++ -march=rv32im
CC  = $(RISCV_TOOLS_PREFIX)gcc -march=rv32im -O1 -fpack-struct
AS  = $(RISCV_TOOLS_PREFIX)gcc -march=rv32im
LDFLAGS = -Wl
LDLIBS  =
MAIN = main_sv_pwm

quartus_$(MAIN).hex: $(MAIN)32.hex
	python3 ../hex8tointel.py $(MAIN).tmp > quartus_$(MAIN).hex
	rm $(MAIN)32.hex

$(MAIN)32.hex: $(MAIN).elf ../hex8tohex32.py
	$(RISCV_TOOLS_PREFIX)objcopy -O verilog $(MAIN).elf $(MAIN).tmp
	$(RISCV_TOOLS_PREFIX)objdump -h -S $(MAIN).elf > "$(MAIN).lss"
	python3 ../hex8tohex32.py $(MAIN).tmp > $(MAIN)32.hex

start.o: ../_core/start.S
	$(CC) -c -nostdlib ../_core/start.S $(LDLIBS)

$(MAIN).elf: $(MAIN).o start.o ../_core/syscalls.o ../_core/utils.o sv_pwm.o
	$(CC) $(LDFLAGS),-Map=$(MAIN).map -o $@ $^ -T ../_core/sections.ld $(LDLIBS)
	chmod -x $(MAIN).elf

clean:
	rm -f ../*/*.o *.o *.d *.tmp start.elf *.lss *.map
	rm -f $(MAIN).elf $(MAIN).hex $(MAIN)32.hex quartus_$(MAIN).hex

-include *.d
.PHONY: clean
