# RISC-V Compiler Installation

> **Viewing Tip:** For better reading of this Markdown document, you can:
> - In VS Code/Editor: Press `Ctrl+Shift+V` to open preview
> - Online: Use [GitHub](https://github.com) or [StackEdit](https://stackedit.io/) for formatted visualization

## Requirements

- Operating System: Windows 10/11, Linux (Ubuntu/Debian/Fedora), or macOS
- Disk space: ~500 MB for toolchain
- Permissions: Access to extract files and execute scripts

---

## GNU RISC-V GCC Toolchain Installation

### Step 1: Download the Compiler

**Access the official repository:**
- Link: [GNU RISC-V GCC Releases](https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack/releases/tag/v11.3.0-1)

**Choose the package according to your operating system:**

| Operating System | File to Download |
|------------------|------------------|
| Windows 64-bit | `xpack-riscv-none-elf-gcc-11.3.0-1-win32-x64.zip` |
| Linux 64-bit | `xpack-riscv-none-elf-gcc-11.3.0-1-linux-x64.tar.gz` |
| macOS 64-bit | `xpack-riscv-none-elf-gcc-11.3.0-1-darwin-x64.tar.gz` |

**Important:** Use version **maximum 11.3.0-1**. Newer versions may not be compatible.

---

### Step 2: Extract the Package

**In terminal (Linux/macOS):**

```bash
# Define directory variables
# Put here the path where you cloned the riscv-multicycle project
PROJECT_DIR="/complete/path/to/riscv-multicycle"

# Example:
# PROJECT_DIR="$HOME/Documents/riscv-multicycle"
# PROJECT_DIR="/home/your_user/projects/riscv-multicycle"

# Define compiler directory
COMPILER_DIR="$PROJECT_DIR/compiler"
DOWNLOAD_FILE="$HOME/Downloads/xpack-riscv-none-elf-gcc-11.3.0-1-linux-x64.tar.gz"

# Navigate to compiler folder
cd "$COMPILER_DIR"

# Extract downloaded file
tar -xzf "$DOWNLOAD_FILE"

# Verify extraction
ls -la
```

**On Windows (PowerShell or Git Bash):**

```bash
# Git Bash on Windows
PROJECT_DIR="/c/Users/your_user/projects/riscv-multicycle"
COMPILER_DIR="$PROJECT_DIR/compiler"
DOWNLOAD_FILE="/c/Users/your_user/Downloads/xpack-riscv-none-elf-gcc-11.3.0-1-win32-x64.zip"

cd "$COMPILER_DIR"

# Extract using unzip (Git Bash)
unzip "$DOWNLOAD_FILE"

# OR use Windows Explorer to extract the .zip file
```

---

### Step 3: Rename the Directory

**In terminal:**

```bash
# Still in compiler directory
cd "$COMPILER_DIR"

# Rename extracted folder to "gcc"
# Original name is something like: xpack-riscv-none-elf-gcc-11.3.0-1
mv xpack-riscv-none-elf-gcc-11.3.0-1 gcc

# Check directory structure
ls -la gcc/bin/

# Should show files like:
# riscv-none-elf-gcc
# riscv-none-elf-g++
# riscv-none-elf-ld
# riscv-none-elf-objdump
# etc.
```

**Expected directory structure:**

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

### Step 4: Update Path in Makefiles

The project Makefiles are already configured to use relative paths.

**Check configuration in Makefiles:**

```bash
# Check configuration in main Makefile
cd "$PROJECT_DIR/software"
grep "RISCV_TOOLS_PREFIX" Makefile
```

**Expected line in Makefile:**
```makefile
RISCV_TOOLS_PREFIX = ../compiler/gcc/bin/riscv-none-elf-
```

**If needed, edit the Makefile:**
```bash
# In terminal
vim "$PROJECT_DIR/software/Makefile"
# or
gedit "$PROJECT_DIR/software/Makefile"
```

**Note:** The path is relative to the folder where the Makefile is located.
- For `software/Makefile`: `../compiler/gcc/bin/riscv-none-elf-`
- For `software/uart/Makefile`: `../../compiler/gcc/bin/riscv-none-elf-`

---

### Step 5: Test the Installation

**In terminal, execute:**

```bash
# Navigate to software folder
cd "$PROJECT_DIR/software"

# Try to compile an example
make clean
make

# If successful, you'll see messages like:
# riscv-none-elf-gcc -c ...
# riscv-none-elf-ld ...
# Compilation successful!
```

**Check compiler directly:**

```bash
# Test compiler version
"$COMPILER_DIR/gcc/bin/riscv-none-elf-gcc" --version

# Expected output:
# riscv-none-elf-gcc (xPack GNU RISC-V Embedded GCC x86_64) 11.3.0
# Copyright (C) 2021 Free Software Foundation, Inc.
```

**Check RV32IM support:**

```bash
# Check supported architectures
"$COMPILER_DIR/gcc/bin/riscv-none-elf-gcc" -march=rv32im -mabi=ilp32 --print-multi-lib
```

---

## Windows Subsystem for Linux (WSL) Installation

### When to use WSL?

- If you're on Windows and want complete Linux environment
- For better compatibility with development tools
- For VS Code integration

### Step 1: Install WSL

**In PowerShell as Administrator:**

```powershell
wsl --install
```

**Official documentation:** [Microsoft WSL Installation Guide](https://docs.microsoft.com/en-us/windows/wsl/install-win10)

---

### Step 2: Install Ubuntu on WSL

**After restarting PC:**

```powershell
# List available distributions
wsl --list --online

# Install Ubuntu (recommended: Ubuntu 22.04 LTS)
wsl --install -d Ubuntu-22.04
```

**Configure user and password when prompted.**

---

### Step 3: Integrate VS Code with WSL

**Install WSL extension in VS Code:**

1. Open VS Code
2. Go to Extensions (Ctrl+Shift+X)
3. Search for "WSL"
4. Install "Remote - WSL" (from Microsoft)

**Complete tutorial:** [VS Code WSL Tutorial](https://devblogs.microsoft.com/commandline/an-in-depth-tutorial-on-linux-development-on-windows-with-wsl-and-visual-studio-code/)

---

### Step 4: Install Compiler on WSL

**Open Ubuntu terminal (WSL):**
- Search for "Ubuntu" in Windows Start Menu
- Or in VS Code: `Ctrl+Shift+P` → "WSL: New Window"

**In Ubuntu terminal, execute the same Linux installation steps:**

```bash
# In WSL Ubuntu
PROJECT_DIR="$HOME/riscv-multicycle"
COMPILER_DIR="$PROJECT_DIR/compiler"

# Clone or copy project to WSL
cd ~
git clone https://github.com/xtarke/riscv-multicycle.git
# OR copy from Windows folder: cp -r /mnt/c/Users/your_user/projects/riscv-multicycle ~

# Download compiler
cd "$COMPILER_DIR"
wget https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack/releases/download/v11.3.0-1/xpack-riscv-none-elf-gcc-11.3.0-1-linux-x64.tar.gz

# Extract
tar -xzf xpack-riscv-none-elf-gcc-11.3.0-1-linux-x64.tar.gz

# Rename
mv xpack-riscv-none-elf-gcc-11.3.0-1 gcc

# Test
cd "$PROJECT_DIR/software"
make clean
make
```

---

## Troubleshooting

### Error: "riscv-none-elf-gcc: command not found"

**Solution:**
```bash
# Check if gcc directory exists
ls -la "$COMPILER_DIR/gcc/bin/"

# Check if path in Makefile is correct
cat "$PROJECT_DIR/software/Makefile" | grep RISCV_TOOLS_PREFIX
```

### Error: "Permission denied" when executing gcc

**Solution on Linux/WSL:**
```bash
# Give execution permission
chmod +x "$COMPILER_DIR/gcc/bin/"*
```

### Error: Incompatible compiler version

**Solution:**
- Make sure to use version **11.3.0-1** or lower
- Versions 12.x may have incompatibilities

### Error: "cannot find -lgcc"

**Solution:**
```bash
# Check if all libraries were extracted
ls -la "$COMPILER_DIR/gcc/lib/gcc/riscv-none-elf/"

# If empty, re-extract the complete package
```

---

## References

- [RISC-V GNU Toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain)
- [xPack RISC-V GCC](https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack)
- [RISC-V Specifications](https://riscv.org/technical/specifications/)


