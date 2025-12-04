# Instalação do Compilador RISC-V

> **Dica de Visualização:** Para melhor leitura deste documento Markdown, você pode:
> - No VS Code/Editor: Pressione `Ctrl+Shift+V` para abrir o preview
> - Online: Use [GitHub](https://github.com) ou [StackEdit](https://stackedit.io/) para visualização formatada

## Requisitos

- Sistema Operacional: Windows 10/11, Linux (Ubuntu/Debian/Fedora), ou macOS
- Espaço em disco: ~500 MB para o toolchain
- Permissões: Acesso para extrair arquivos e executar scripts

---

## Instalação do GNU RISC-V GCC Toolchain

### Passo 1: Download do Compilador

**Acesse o repositório oficial:**
- Link: [GNU RISC-V GCC Releases](https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack/releases/tag/v11.3.0-1)

**Escolha o pacote de acordo com seu sistema operacional:**

| Sistema Operacional | Arquivo para Download |
|---------------------|----------------------|
| Windows 64-bit | `xpack-riscv-none-elf-gcc-11.3.0-1-win32-x64.zip` |
| Linux 64-bit | `xpack-riscv-none-elf-gcc-11.3.0-1-linux-x64.tar.gz` |
| macOS 64-bit | `xpack-riscv-none-elf-gcc-11.3.0-1-darwin-x64.tar.gz` |

**Importante:** Utilize a versão **máxima 11.3.0-1**. Versões mais recentes podem não ser compatíveis.

---

### Passo 2: Extrair o Pacote

**No terminal (Linux/macOS):**

```bash
# Defina variáveis de diretório
# Coloque aqui o path onde você clonou o projeto riscv-multicycle
PROJECT_DIR="/caminho/completo/ate/riscv-multicycle"

# Exemplo:
# PROJECT_DIR="$HOME/Documents/riscv-multicycle"
# PROJECT_DIR="/home/seu_usuario/projetos/riscv-multicycle"

# Defina o diretório do compilador
COMPILER_DIR="$PROJECT_DIR/compiler"
DOWNLOAD_FILE="$HOME/Downloads/xpack-riscv-none-elf-gcc-11.3.0-1-linux-x64.tar.gz"

# Navegue até a pasta compiler
cd "$COMPILER_DIR"

# Extraia o arquivo baixado
tar -xzf "$DOWNLOAD_FILE"

# Verifique a extração
ls -la
```

**No Windows (PowerShell ou Git Bash):**

```bash
# Git Bash no Windows
PROJECT_DIR="/c/Users/seu_usuario/projetos/riscv-multicycle"
COMPILER_DIR="$PROJECT_DIR/compiler"
DOWNLOAD_FILE="/c/Users/seu_usuario/Downloads/xpack-riscv-none-elf-gcc-11.3.0-1-win32-x64.zip"

cd "$COMPILER_DIR"

# Extrair usando unzip (Git Bash)
unzip "$DOWNLOAD_FILE"

# OU use o Windows Explorer para extrair o arquivo .zip
```

---

### Passo 3: Renomear o Diretório

**No terminal:**

```bash
# Ainda no diretório compiler
cd "$COMPILER_DIR"

# Renomear a pasta extraída para "gcc"
# O nome original é algo como: xpack-riscv-none-elf-gcc-11.3.0-1
mv xpack-riscv-none-elf-gcc-11.3.0-1 gcc

# Verificar estrutura de diretórios
ls -la gcc/bin/

# Deve mostrar arquivos como:
# riscv-none-elf-gcc
# riscv-none-elf-g++
# riscv-none-elf-ld
# riscv-none-elf-objdump
# etc.
```

**Estrutura de diretórios esperada:**

```
riscv-multicycle/
└── compiler/
    └── gcc/
        ├── bin/
        │   ├── riscv-none-elf-gcc
        │   ├── riscv-none-elf-g++
        │   ├── riscv-none-elf-ld
        │   ├── riscv-none-elf-objdump
        │   └── ...
        ├── lib/
        ├── libexec/
        └── share/
```

---

### Passo 4: Atualizar o Caminho nos Makefiles

Os Makefiles do projeto já estão configurados para usar o caminho relativo.

**Verifique a configuração nos Makefiles:**

```bash
# Verificar configuração no Makefile principal
cd "$PROJECT_DIR/software"
grep "RISCV_TOOLS_PREFIX" Makefile
```

**Linha esperada no Makefile:**
```makefile
RISCV_TOOLS_PREFIX = ../compiler/gcc/bin/riscv-none-elf-
```

**Se necessário, edite o Makefile:**
```bash
# No terminal
vim "$PROJECT_DIR/software/Makefile"
# ou
gedit "$PROJECT_DIR/software/Makefile"
```

**Observação:** O caminho é relativo à pasta onde o Makefile está localizado.
- Para `software/Makefile`: `../compiler/gcc/bin/riscv-none-elf-`
- Para `software/uart/Makefile`: `../../compiler/gcc/bin/riscv-none-elf-`

---

### Passo 5: Testar a Instalação

**No terminal, execute:**

```bash
# Navegar para a pasta de software
cd "$PROJECT_DIR/software"

# Tentar compilar um exemplo
make clean
make

# Se compilar com sucesso, você verá mensagens como:
# riscv-none-elf-gcc -c ...
# riscv-none-elf-ld ...
# Compilation successful!
```

**Verificar o compilador diretamente:**

```bash
# Testar versão do compilador
"$COMPILER_DIR/gcc/bin/riscv-none-elf-gcc" --version

# Saída esperada:
# riscv-none-elf-gcc (xPack GNU RISC-V Embedded GCC x86_64) 11.3.0
# Copyright (C) 2021 Free Software Foundation, Inc.
```

**Verificar suporte para RV32IM:**

```bash
# Verificar arquiteturas suportadas
"$COMPILER_DIR/gcc/bin/riscv-none-elf-gcc" -march=rv32im -mabi=ilp32 --print-multi-lib
```

---

## Instalação no Windows Subsystem for Linux (WSL)

### Quando usar WSL?

- Se você está no Windows e quer ambiente Linux completo
- Para melhor compatibilidade com ferramentas de desenvolvimento
- Para integração com VS Code

### Passo 1: Instalar o WSL

**No PowerShell como Administrador:**

```powershell
wsl --install
```

**Documentação oficial:** [Microsoft WSL Installation Guide](https://docs.microsoft.com/en-us/windows/wsl/install-win10)

---

### Passo 2: Instalar Ubuntu no WSL

**Após reiniciar o PC:**

```powershell
# Listar distribuições disponíveis
wsl --list --online

# Instalar Ubuntu (recomendado: Ubuntu 22.04 LTS)
wsl --install -d Ubuntu-22.04
```

**Configurar usuário e senha quando solicitado.**

---

### Passo 3: Integrar VS Code com WSL

**Instalar extensão WSL no VS Code:**

1. Abra o VS Code
2. Vá em Extensions (Ctrl+Shift+X)
3. Busque "WSL"
4. Instale "Remote - WSL" (da Microsoft)

**Tutorial completo:** [VS Code WSL Tutorial](https://devblogs.microsoft.com/commandline/an-in-depth-tutorial-on-linux-development-on-windows-with-wsl-and-visual-studio-code/)

---

### Passo 4: Instalar o Compilador no WSL

**Abra o terminal Ubuntu (WSL):**
- Busque "Ubuntu" no menu Iniciar do Windows
- Ou no VS Code: `Ctrl+Shift+P` → "WSL: New Window"

**No terminal Ubuntu, execute os mesmos passos de instalação Linux:**

```bash
# No WSL Ubuntu
PROJECT_DIR="$HOME/riscv-multicycle"
COMPILER_DIR="$PROJECT_DIR/compiler"

# Clone ou copie o projeto para o WSL
cd ~
git clone https://github.com/xtarke/riscv-multicycle.git
# OU copie da pasta Windows: cp -r /mnt/c/Users/seu_usuario/projetos/riscv-multicycle ~

# Baixar o compilador
cd "$COMPILER_DIR"
wget https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack/releases/download/v11.3.0-1/xpack-riscv-none-elf-gcc-11.3.0-1-linux-x64.tar.gz

# Extrair
tar -xzf xpack-riscv-none-elf-gcc-11.3.0-1-linux-x64.tar.gz

# Renomear
mv xpack-riscv-none-elf-gcc-11.3.0-1 gcc

# Testar
cd "$PROJECT_DIR/software"
make clean
make
```

---

## Troubleshooting

### Erro: "riscv-none-elf-gcc: command not found"

**Solução:**
```bash
# Verifique se o diretório gcc existe
ls -la "$COMPILER_DIR/gcc/bin/"

# Verifique se o caminho no Makefile está correto
cat "$PROJECT_DIR/software/Makefile" | grep RISCV_TOOLS_PREFIX
```

### Erro: "Permission denied" ao executar gcc

**Solução no Linux/WSL:**
```bash
# Dar permissão de execução
chmod +x "$COMPILER_DIR/gcc/bin/"*
```

### Erro: Versão incompatível do compilador

**Solução:**
- Certifique-se de usar versão **11.3.0-1** ou inferior
- Versões 12.x podem ter incompatibilidades

### Erro: "cannot find -lgcc"

**Solução:**
```bash
# Verificar se todas as bibliotecas foram extraídas
ls -la "$COMPILER_DIR/gcc/lib/gcc/riscv-none-elf/"

# Se estiver vazio, re-extraia o pacote completo
```

---

## Referências

- [RISC-V GNU Toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain)
- [xPack RISC-V GCC](https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack)
- [RISC-V Specifications](https://riscv.org/technical/specifications/)

