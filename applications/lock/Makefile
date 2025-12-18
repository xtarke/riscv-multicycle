# =====================================================
# Toolchain RISC-V
# =====================================================

ifndef RISCV_TOOLS_PREFIX
RISCV_TOOLS_PREFIX = ../../compiler/gcc/bin/riscv-none-elf-
# Para usar no LSC
# RISCV_TOOLS_PREFIX = ~/opt/xPacks/@xpack-dev-tools/riscv-none-embed-gcc/8.3.0-1.1.1/.content/bin/riscv-none-elf-
endif

# =====================================================
# Quartus
# =====================================================
QUARTUS_DIR = /opt/intelFPGA/19.1/quartus/bin/

# =====================================================
# Compiladores
# =====================================================
CXX = $(RISCV_TOOLS_PREFIX)g++ -march=rv32im -mabi=ilp32

CC  = $(RISCV_TOOLS_PREFIX)gcc -march=rv32im -mabi=ilp32 \
      -O1 -fpack-struct \
      -I ../../software/_core \
      -I ../../software/irq  \
      -I ../../software/gpio

AS  = $(RISCV_TOOLS_PREFIX)gcc -march=rv32im -mabi=ilp32

# =====================================================
# Linkagem
# =====================================================
LDFLAGS = -Wl,-Map=$(MAIN).map
LDLIBS  =

MAIN = main

# =====================================================
# Geração dos HEX
# =====================================================

quartus_$(MAIN).hex: $(MAIN)32.hex
	python3 ../../software/hex8tointel.py $(MAIN).tmp > quartus_$(MAIN).hex
	rm -f $(MAIN)32.hex

$(MAIN)32.hex: $(MAIN).elf ../../software/hex8tohex32.py
	$(RISCV_TOOLS_PREFIX)objcopy -O verilog $(MAIN).elf $(MAIN).tmp
	$(RISCV_TOOLS_PREFIX)objdump -h -S $(MAIN).elf > $(MAIN).lss
	python3 ../../software/hex8tohex32.py $(MAIN).tmp > $(MAIN)32.hex

# =====================================================
# Objetos
# =====================================================

start.o: ../../software/_core/start.S
	$(CC) -c -nostdlib $< -o $@

# =====================================================
# Link final
# =====================================================

$(MAIN).elf: $(MAIN).o start.o \
             ../../software/_core/syscalls.o \
             ../../software/_core/utils.o \
             ../../software/gpio/gpio.c
	$(CC) $(LDFLAGS) -o $@ $^ \
	-T ../../software/_core/sections.ld $(LDLIBS)
	chmod -x $(MAIN).elf

# =====================================================
# Quartus (opcional no WSL)
# =====================================================

sint:
	$(QUARTUS_DIR)quartus_sh --flow compile \
	../peripherals/gpio/sint/de10_lite/de10_lite.cdf

fpga:
	$(QUARTUS_DIR)quartus_pgm -z -m JTAG \
	-o "p;../peripherals/gpio/sint/de10_lite/output_files/de10_lite.sof"

flash:
	$(QUARTUS_DIR)quartus_stp_tcl -t flash.tcl

# =====================================================
# Limpeza
# =====================================================

clean:
	rm -f ../*/*.o *.o *.d *.tmp *.lss *.map
	rm -f $(MAIN).elf $(MAIN).hex $(MAIN)32.hex quartus_$(MAIN).hex

-include *.d
.PHONY: clean sint fpga flash

