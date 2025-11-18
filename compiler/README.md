# Instalação do compilador

1. Baixar [GNU RISC-C GCC](https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack/releases/tag/v11.3.0-1) de acordo com SO do seu PC. Win32-x64 para Windows ou Linux-x64 para Linux.

    - Utilize a versão máxima 11.3, por exemplo: **xpack-riscv-none-elf-gcc-11.3.0-1-linux-x64.tar.gz**

2. Extrair o pacote.

3. Renomear o diretório "xpack-riscv-..." para gcc criando a seguinte árvore de aquivos:

```C
./compiler/gcc/bin/+
                   |- riscv-none-elf-gcc 
                   |- (...)	
```

4. Atualize o caminho de cada **Makefile**:

```C
RISCV_TOOLS_PREFIX = ../compiler/gcc/bin/riscv-none-elf-

```

5. Digite **make** para compilar.

## Instalação do Windows Subsystem for Linux

1. Instalar o WSL: [Microsoft Docs](https://docs.microsoft.com/en-us/windows/wsl/install-win10)

2. Instalar o Ubuntu no WSL

	- Para integrar o Visual Code com o compilador interno ao WSL, siga esse [link](https://devblogs.microsoft.com/commandline/an-in-depth-tutorial-on-linux-development-on-windows-with-wsl-and-visual-studio-code/)

3. No shell Ubuntu (busque Ubuntu no Iniciar do Windows), siga os passos acima.

