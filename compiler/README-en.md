# Compiler installation

1. Download [GNU RISC-C GCC](https://github.com/xpack-dev-tools/riscv-none-embed-gcc-xpack/releases) according to your host SO. Win32-x64 for Windows or Linux-x64 for Linux.

    - Use version 11.3, for instance: **xpack-riscv-none-elf-gcc-11.3.0-1-linux-x64.tar.gz**

2. Extract the downloaded package.

3. Rename the folder "xpack-riscv-..." to **gcc** creating the following tree:

```C
./compiler/gcc/bin/+
                   |- riscv-none-elf-gcc 
                   |- (...)	
```

4. Update the path in each **Makefile**:

```C
RISCV_TOOLS_PREFIX = ../compiler/gcc/bin/riscv-none-elf-

```

5. Type **make** to compile.

## Windows Subsystem for Linux installation

1. Install WSL: [Microsoft Docs](https://docs.microsoft.com/en-us/windows/wsl/install-win10).

2. Install WSL Ubuntu.

	- Follow this [link](https://devblogs.microsoft.com/commandline/an-in-depth-tutorial-on-linux-development-on-windows-with-wsl-and-visual-studio-code/) in order to integrate a compiler in Visual Code.
        
3. In the Ubuntu Shell (search for Ubuntu in Windows Start Menu), follow the same above steps.


