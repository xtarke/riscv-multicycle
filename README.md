# RISC SoftCore

[![en](https://img.shields.io/badge/lang-en-red.svg)](./README-en.md)

RISC SoftCore é uma implementação em VHDL com fins diádicos do conjunto de instruções RISCV RV32IM. Essa versão particular não implementa um pipeline. A ideia é criar um microcontrolador com periféricos comuns como I2C, USART, SPI e GPIOs inicialmente utilizado para disciplina de Dispositivos Lógicos Programáveis.

Ferramentas de programação podem ser obtidas no [Compliler](https://github.com/xpack-dev-tools/riscv-none-embed-gcc-xpack/releases).

Animação do funcionamento da arquitetura em [Virgularor: minimum RISC-V](http://tice.sea.eseo.fr/riscv/)

Simulador assembly baseado no MARS: [RARS](https://github.com/TheThirdOne/rars)

![Diagrama Núcleo](./readme_img/core.svg)

## Getting Started (hardware):

- Simulação:
    - Execute o script script [testbench.do](./testbench.do) no Modelsim (Altera Edition).
    - Testbench principal: [testbench.vhd](./testbench.vhd). Simula o núcleo, um timer e pinos de propósito geral (gpio e display de 7 segmentos).
    - Verifique se o arquivo de programa está apontado corretamente (i.e.: __./software/quartus_blink.hex__) no módulo [iram_quartus.vhdl](./memory/iram_quartus.vhd).
    - Veja esse [diagrama completo do testbench](./readme_img/testbench.svg)

- Síntese: Quartus 19.1 ou superior (testado no Kit de desenvolvimento DE10-Lite)
    - Abra o projeto genérico em [./peripherals/gpio/sint/de10_lite/](./peripherals/gpio/sint/de10_lite/)
    - Para gravação do programa pós síntese:
        - Menu principal do Quartus: Tools -> In-System Memory Editor

## Getting Started (software):

A compilação de programas necessita do _toolchain_ __riscv32-unknown-elf__ (ou __riscv-none-embed__) suportando o subconjunto __RV32IM__, __sem ABI__. Em ./software/ há vários exemplos. Perceba que na fase atual do projeto utilizamos um _script_ de _linker_ customizado (sections.ld). _libc_ ainda não foi testado/suportado.

### Instalação do compilador no Linux

Guia para instalação no [gnu-mcu-eclipse.github.io](https://gnu-mcu-eclipse.github.io/toolchain/riscv/install/#gnulinux)

Toolchain Release: riscv-none-gcc [Github](https://github.com/xpack-dev-tools/riscv-none-embed-gcc-xpack/releases).

Na utilização do xPacks talvez seja necessário exportar o `XPACKS_REPO_FOLDER`:

```export XPACKS_REPO_FOLDER=~/opt/xPacks/```

Instruções para Arch Linux (adaptar para outras distribuições):
```
sudo pacman -Syyu npm
sudo npm install --global xpm@latest
export XPACKS_REPO_FOLDER=~/opt/xPacks/
mkdir -p $XPACKS_REPO_FOLDER
xpm install --global @xpack-dev-tools/riscv-none-embed-gcc@latest
export MY_PLD_WORKSPACE=~/workspace_vhdl
mkdir -p $MY_PLD_WORKSPACE
cd $MY_PLD_WORKSPACE
git clone https://github.com/xtarke/riscv-multicycle
cd $MY_PLD_WORKSPACE/riscv-multicycle/tests
```

1. Atualizar Makefile com o diretório da toolchain.

Exemplo:

```RISCV_TOOLS_PREFIX = ~/opt/xPacks/@xpack-dev-tools/riscv-none-embed-gcc/8.3.0-1.1.1/.content/bin/riscv-none-embed-```

2. Para compilar, _make_.

### Instalação do compilador no Windows (Windows Subsystem for Linux)

1. Instalar o WSL: [Microsoft Docs](https://docs.microsoft.com/en-us/windows/wsl/install-win10)
2. Instalar o Ubuntu no WSL

	- Para integrar o Visual Code com o compilador interno ao WSL, siga esse [link](https://devblogs.microsoft.com/commandline/an-in-depth-tutorial-on-linux-development-on-windows-with-wsl-and-visual-studio-code/)

3. No shell Ubuntu (busque Ubuntu no Iniciar do Windows):
4. Instalar os pacotes para o nodejs:

```sudo apt update
sudo apt upgrade
sudo apt install nodejs
sudo apt install npm
sudo npm --global install xpm
```

5. Instalar por xmp [GNU Eclipse](https://gnu-mcu-eclipse.github.io/toolchain/riscv/install/):

```xpm install --global @gnu-mcu-eclipse/riscv-none-gcc```

6. Altere o caminho do compilador no _Makefile_:
	- de:
```RISCV_TOOLS_PREFIX = riscv32-unknown-elf-```
	- para:
```RISCV_TOOLS_PREFIX = ~/opt/xPacks/@<versão compilador>/.contents/bin/riscv-none-embed-```

7. Utilizando o shell Ubuntu,  mude o diretório atual para o repositório:

```cd /mnt/c/<caminho sistema arquivos Windows>```

8. Para compilar, _make_.

Após a compilação, mova, copie ou faça um _link_ simbólico de ./tests/quartus.hex para a raiz do projeto.
