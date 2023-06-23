
# TODO
- [ ] Alterar a posição de memória em:
    https://github.com/ArielRM/riscv-multicycle/blob/c52c943c36a59460a284f738c3da6b2f9ca0e049/software/_core/hardware.h#L80
    https://github.com/ArielRM/riscv-multicycle/blob/c52c943c36a59460a284f738c3da6b2f9ca0e049/memory/iodatabusmux.vhd#L29
    https://github.com/ArielRM/riscv-multicycle/blob/c52c943c36a59460a284f738c3da6b2f9ca0e049/software/_core/hardware.h#L80
- [ ] Terminar esse README

# Periférico CRC

# Simulação do componente
- Executar o script `peripherals/crc/crc.do` no ModelSim/Questa
```console
ModelSim> pwd
# peripherals/crc
ModelSim> do crc.do
```

# Simulação com `core`
- Compilar o código de teste `software/crc/main.c`
```console
foo@bar:software/crc$ make
--------------------------- ESSA É A SAÍDA ESPERADA ------------------------------------------------
../../compiler/gcc/bin/riscv-none-elf-gcc -march=rv32im -O1 -fpack-struct    -c -o main.o main.c
../../compiler/gcc/bin/riscv-none-elf-gcc -march=rv32im -O1 -fpack-struct -c -nostdlib ../_core/start.S
../../compiler/gcc/bin/riscv-none-elf-gcc -march=rv32im -O1 -fpack-struct    -c -o ../_core/syscalls.o ../_core/syscalls.c
../../compiler/gcc/bin/riscv-none-elf-gcc -march=rv32im -O1 -fpack-struct    -c -o ../_core/utils.o ../_core/utils.c
../../compiler/gcc/bin/riscv-none-elf-gcc -march=rv32im -O1 -fpack-struct    -c -o ../gpio/gpio.o ../gpio/gpio.c
../../compiler/gcc/bin/riscv-none-elf-gcc -march=rv32im -O1 -fpack-struct    -c -o ../irq/interrupt.o ../irq/interrupt.c
../../compiler/gcc/bin/riscv-none-elf-gcc -march=rv32im -O1 -fpack-struct -Wl,-Map=main.map -o main.elf main.o start.o ../_core/syscalls.o ../_core/utils.o ../gpio/gpio.o ../irq/interrupt.o -T ../_core/sections.ld
chmod -x main.elf
../../compiler/gcc/bin/riscv-none-elf-objcopy -O verilog main.elf main.tmp
../../compiler/gcc/bin/riscv-none-elf-objdump -h -S main.elf > "main.lss"
python3 ../hex8tohex32.py main.tmp > main32.hex
python3 ../hex8tointel.py main.tmp > quartus_main.hex
rm main32.hex
--------------------------- FIM DA SAÍDA ESPERADA ------------------------------------------------
foo@bar:software/crc$ |
```
- Substituir o valor de `init_file` em `memory/iram_quartus.vhd` por `./software/crc/quartus_main.hex`
```diff
- init_file => "./software/irq/quartus_irq_example.hex",
+ init_file => "./software/crc/quartus_main.hex",
```
- Executar o script `peripherals/crc/core.do` no ModelSim/Questa
```console
ModelSim> pwd
# peripherals/crc
ModelSim> do core.do
```

