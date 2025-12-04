# RISC SoftCore

[![en](https://img.shields.io/badge/lang-en-red.svg)](./README-en.md)

> **Dica de Visualização:** Para melhor leitura deste documento Markdown, você pode:
> - No VS Code/Editor: Pressione `Ctrl+Shift+V` para abrir o preview
> - Online: Use [GitHub](https://github.com) ou [MarkdownLivePreview](https://markdownlivepreview.com/) para visualização formatada

RISC SoftCore é uma implementação em VHDL com fins diádicos do conjunto de instruções RISCV RV32IM. Essa versão particular não implementa um pipeline. A ideia é criar um microcontrolador com periféricos comuns como I2C, USART, SPI e GPIOs inicialmente utilizado para disciplina de Dispositivos Lógicos Programáveis.

Ferramentas de programação podem ser obtidas no [Compliler](https://github.com/xpack-dev-tools/riscv-none-embed-gcc-xpack/releases).

Animação do funcionamento da arquitetura em [Virgularor: minimum RISC-V](http://tice.sea.eseo.fr/riscv/)

Simulador assembly baseado no MARS: [RARS](https://github.com/TheThirdOne/rars)

![Diagrama Núcleo](./readme_img/core.svg)

## Requisitos do Sistema

### Hardware
- FPGA DE10-Lite (Intel/Altera MAX 10) ou compatível
- Cabo USB Blaster para programação e debugging
- Computador com pelo menos 4GB de RAM

### Software
- **Simulação:** ModelSim-Altera Edition 20.1 ou superior
- **Síntese:** Quartus Prime Lite 19.1 ou superior
- **Compilação:** Toolchain RISC-V (riscv-none-elf-gcc ou riscv-none-embed-gcc)
  - Suporte para RV32IM
  - Sem ABI (bare-metal)

## Getting Started

### 1. Simulação no ModelSim

A simulação permite testar o núcleo e periféricos antes da síntese.

**Passo 1:** Abra o ModelSim-Altera Edition

**Passo 2:** Configure as variáveis de diretório no terminal

**Importante:** Execute os comandos abaixo no terminal bash/shell.

```bash
# Variáveis de diretório - AJUSTE O CAMINHO ABAIXO
# Coloque aqui o path completo onde você clonou/extraiu o projeto
PROJECT_DIR="/caminho/completo/ate/riscv-multicycle"

# Exemplo no Linux:
# PROJECT_DIR="/home/seu_usuario/projetos/riscv-multicycle"
# PROJECT_DIR="$HOME/Documents/riscv-multicycle"

# Exemplo no Windows (Git Bash/WSL):
# PROJECT_DIR="/c/Users/seu_usuario/projetos/riscv-multicycle"
# PROJECT_DIR="/mnt/c/Users/seu_usuario/projetos/riscv-multicycle"

# Definir variáveis derivadas (NÃO ALTERE ESTAS)
SOFTWARE_DIR="$PROJECT_DIR/software"
MEMORY_DIR="$PROJECT_DIR/memory"

# Navegar para o diretório do projeto
cd "$PROJECT_DIR"
```

**Passo 3:** Execute o script de simulação
```tcl
do testbench.do
```

**Passo 4:** Verifique o arquivo de programa
```bash
# Edite o arquivo de memória para apontar para seu programa
vim "$MEMORY_DIR/iram_quartus.vhd"
# ou
gedit "$MEMORY_DIR/iram_quartus.vhd"
```
- Localize a linha que carrega o arquivo `.hex`
- Aponte para o programa desejado:
```vhdl
-- Exemplo de configuração no iram_quartus.vhd:
file_name := "$SOFTWARE_DIR/quartus_blink.hex";
```

**Passo 5:** Execute a simulação
- No ModelSim, clique em "Run" ou execute: `run -all`
- Observe as formas de onda dos sinais

**Componentes simulados:**
- Núcleo RISC-V RV32IM
- Timer periférico
- GPIO (pinos de propósito geral)
- Display de 7 segmentos

**Diagrama completo:** [testbench.svg](./readme_img/testbench.svg)

**Troubleshooting:**
- **Erro de compilação:** Verifique se todos os arquivos .vhd estão no projeto
- **Arquivo .hex não encontrado:** Use caminho absoluto ou relativo correto
- **Simulação não inicia:** Verifique a versão do ModelSim (requer Altera Edition)

---

### 2. Síntese no Quartus Prime

Síntese gera o bitstream para programação da FPGA.

**Passo 1:** Abra o Quartus Prime Lite Edition

**Passo 2:** Abra o projeto de exemplo

**No terminal**, execute:

```bash
# Variáveis para síntese (certifique-se que PROJECT_DIR está definido)
QUARTUS_PROJECT="$PROJECT_DIR/peripherals/gpio/sint/de10_lite"
PROJECT_FILE="$QUARTUS_PROJECT/de10_lite.qpf"

# Abra o projeto no Quartus via linha de comando
quartus "$PROJECT_FILE" &

# OU navegue manualmente no terminal:
cd "$QUARTUS_PROJECT"
# E depois abra o Quartus pela interface gráfica
```
- Abra o arquivo `.qpf` (Quartus Project File) no Quartus Prime

**Passo 3:** Configure o dispositivo
- Verifique se o dispositivo está configurado como `10M50DAF484C7G` (DE10-Lite)
- Menu: Assignments -> Device

**Passo 4:** Compile o projeto
- Menu: Processing -> Start Compilation
- Ou pressione `Ctrl+L`
- Aguarde a compilação (pode levar vários minutos)

**Passo 5:** Programe a FPGA
- Conecte a placa DE10-Lite via USB
- Menu: Tools -> Programmer
- Selecione o arquivo `.sof` gerado
- Clique em "Start" para programar

**Passo 6:** Gravação do programa na memória (pós-síntese)
- Menu: Tools -> In-System Memory Editor
- Conecte-se à FPGA
- Carregue o arquivo `.hex` do seu programa
- Escreva na memória de instruções

**Recursos utilizados (típico):**
- Logic Elements: ~3000-4000 LEs
- Memory bits: ~100Kb
- Frequência máxima: ~50 MHz

**Troubleshooting:**
- **Erro de timing:** Reduza a frequência do clock ou otimize o código
- **FPGA não detectada:** Verifique drivers do USB Blaster
- **Erro de pinos:** Confirme o arquivo de constraints (.qsf)

---

### 3. Compilação de Software

Crie programas em C/Assembly para o núcleo RISC-V.

**Requisitos do Toolchain:**
- Compilador: `riscv-none-elf-gcc` ou `riscv-none-embed-gcc`
- Arquitetura: RV32IM (32-bit com multiplicação/divisão)
- ABI: Bare-metal (sem sistema operacional)
- Versão recomendada: GCC 10.2.0 ou superior

**Instalação do Toolchain:**

Veja o guia completo de instalação em [compiler/README.md](./compiler/README.md)

**Download:**
- [RISC-V GNU Toolchain Releases](https://github.com/xpack-dev-tools/riscv-none-embed-gcc-xpack/releases)

**Verificação da instalação:**
```bash
riscv-none-elf-gcc --version
```

**Passo 1:** Configure as variáveis e navegue até a pasta de exemplos

**No terminal**, execute:

```bash
# Variáveis de diretório - AJUSTE O CAMINHO ABAIXO
# Coloque aqui o path completo onde você clonou/extraiu o projeto
PROJECT_DIR="/caminho/completo/ate/riscv-multicycle"

# Definir variável derivada
SOFTWARE_DIR="$PROJECT_DIR/software"

# Navegar para a pasta de software
cd "$SOFTWARE_DIR"
```

**Passo 2:** Escolha um exemplo
```bash
# Exemplos disponíveis:
ls -l "$SOFTWARE_DIR"

# blink.c        - Pisca LED (exemplo básico)
# gpio/          - Controle de pinos GPIO
# uart/          - Comunicação serial
# timer/         - Uso de timers
# spi/           - Comunicação SPI
# i2c/           - Comunicação I2C
# modbus/        - Protocolo Modbus RTU
```

**Passo 3:** Compile o programa
```bash
# Para o exemplo principal (blink)
cd "$SOFTWARE_DIR"
make clean
make

# Para um periférico específico (exemplo: UART)
cd "$SOFTWARE_DIR/uart"
make clean
make
```

**Passo 4:** Verifique os arquivos gerados
- `program.elf` - Arquivo executável
- `program.hex` - Arquivo para gravação (formato Intel HEX)
- `program.lst` - Listing com assembly e endereços

**Estrutura do Projeto:**
- `sections.ld` - Linker script customizado (define layout de memória)
- `Makefile` - Automação da compilação
- `*.c` - Código-fonte em C
- `*.S` - Código assembly

**Mapa de Memória:**
```
0x00000000 - 0x00003FFF : RAM de instruções (16KB)
0x00004000 - 0x00007FFF : RAM de dados (16KB)
0x80000000 - 0x8FFFFFFF : Periféricos mapeados em memória
```

**Observações importantes:**
- A `libc` padrão ainda não é suportada
- Use funções bare-metal para I/O
- O linker script customizado é obrigatório
- Interrupções devem ser configuradas manualmente

**Troubleshooting:**
- **Comando não encontrado:** Adicione o toolchain ao PATH
- **Erro de linking:** Verifique o arquivo `sections.ld`
- **Programa não executa:** Confirme o mapa de memória
- **Código muito grande:** Otimize com `-Os` ou reduza funcionalidades

---

## Exemplos de Uso

**Nota:** Execute todos os comandos abaixo no terminal bash/shell.

### Exemplo 1: Blink LED
```bash
# Defina as variáveis de diretório (ajuste o caminho)
# Coloque aqui o path onde você salvou o projeto
PROJECT_DIR="/caminho/completo/ate/riscv-multicycle"
SOFTWARE_DIR="$PROJECT_DIR/software"

cd "$SOFTWARE_DIR"
make clean
make

# Verificar arquivo gerado:
ls -lh "$SOFTWARE_DIR/quartus_blink.hex"
```

### Exemplo 2: Comunicação UART
```bash
UART_DIR="$SOFTWARE_DIR/uart"

cd "$UART_DIR"
# Configure baudrate no código antes de compilar
vim "$UART_DIR/main.c"  # ou seu editor preferido

make clean
make

# Arquivo gerado:
ls -lh "$UART_DIR/"*.hex
```

### Exemplo 3: Periférico Modbus RTU
```bash
MODBUS_DIR="$PROJECT_DIR/peripherals/modbus"

cd "$MODBUS_DIR"

# Veja documentação completa:
cat "$MODBUS_DIR/README.md"
# ou abra no navegador:
xdg-open "$MODBUS_DIR/README.md"

# Simule no ModelSim:
cd "$PROJECT_DIR"
vsim -do "$MODBUS_DIR/tb_modbus.do"
```

---

## Recursos Adicionais

- **Simulador Assembly:** [RARS - RISC-V Assembler and Runtime Simulator](https://github.com/TheThirdOne/rars)
- **Animação da Arquitetura:** [Virgularor: minimum RISC-V](http://tice.sea.eseo.fr/riscv/)
- **Especificação RISC-V:** [riscv.org/specifications](https://riscv.org/technical/specifications/)


