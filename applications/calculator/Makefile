RISCV_TOOLS_PREFIX = C:/riscv/xpack-riscv-none-embed-gcc-10.2.0-1.2/bin/riscv-none-embed-

CC = $(RISCV_TOOLS_PREFIX)gcc -march=rv32im -O1 -fpack-struct -I ../../software/
AS = $(RISCV_TOOLS_PREFIX)gcc -march=rv32im

LDFLAGS = -Wl
LDLIBS =
MAIN = main

quartus_$(MAIN).hex: $(MAIN)32.hex
	python3 ../../software/hex8tointel.py $(MAIN).tmp > quartus_$(MAIN).hex

$(MAIN)32.hex: $(MAIN).elf ../../software/hex8tohex32.py
	$(RISCV_TOOLS_PREFIX)objcopy -O verilog $(MAIN).elf $(MAIN).tmp
	$(RISCV_TOOLS_PREFIX)objdump -h -S $(MAIN).elf > "$(MAIN).lss"
	python3 ../../software/hex8tohex32.py $(MAIN).tmp > $(MAIN)32.hex

start.o: ../../software/_core/start.S
	$(CC) -c -nostdlib ../../software/_core/start.S $(LDLIBS)

../../software/_core/syscalls.o:
	$(CC) -c ../../software/_core/syscalls.c -o ../../software/_core/syscalls.o

../../software/_core/utils.o:
	$(CC) -c ../../software/_core/utils.c -o ../../software/_core/utils.o

$(MAIN).elf: $(MAIN).o start.o ../../software/_core/syscalls.o ../../software/_core/utils.o
	$(CC) $(LDFLAGS),-Map=$(MAIN).map -o $@ $^ -T ../../software/_core/sections.ld $(LDLIBS)

clean:
	rm -f *.o *.d *.tmp *.lss *.map
	rm -f $(MAIN).elf $(MAIN).hex $(MAIN)32.hex quartus_$(MAIN).hex

.PHONY: clean

-include *.d