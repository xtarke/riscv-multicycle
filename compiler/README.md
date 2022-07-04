# Instalação do compilador

1. Baixar [GNU RISC-C GCC](https://github.com/xpack-dev-tools/riscv-none-embed-gcc-xpack/releases) de acordo com SO do seu PC. Win32-x64 para Windows ou Linux-x64 para Linux.

2. Extrair o pacote.

3. Renomear o diretório "xpack-riscv-..." para gcc criando a seguinte árvore de aquivos:

```C
./compiler/gcc/bin/+
                   |- riscv-none-embed-gcc 
                   |- (...)	
```
