# Guia Inicial para Desenvolvimento de Aplicações RISC-V no FPGA

Este guia foi elaborado para **alunos que pretendem desenvolver uma aplicação no futuro** e estão completamente perdidos sobre por onde começar. Seguindo os passos abaixo, você conseguirá preparar o ambiente, rodar o primeiro exemplo e evoluir gradualmente até sua aplicação final.

---

## Sistema Operacional

**Não tente, em hipótese alguma, rodar o projeto diretamente no Windows.**

Utilize uma das opções abaixo:
- **Linux nativo;**
- **WSL (Windows Subsystem for Linux).**

Siga o tutorial abaixo para instalar o WSL:
https://github.com/xtarke/riscv-multicycle/tree/master/compiler#instala%C3%A7%C3%A3o-no-windows-subsystem-for-linux-wsl

**É importante lembrar que para que os proximos passos funcionem você deve ter seguido o passo-a-passo presente na pasta ../compiler**


## Primeiro Objetivo: Rodar o Código de Exemplo `blink.c`

Com o ambiente Linux ou WSL funcionando, o primeiro passo é **fazer o código de exemplo `blink.c` rodar corretamente**.

O arquivo está localizado em:  ../software/blink.c

### Passo a passo no Quartus

1. Abra o **Quartus**
2. Abra o projeto: `../peripherals/gpio/sint/de10_lite/de10_lite.qpf`
3. Compile o arquivo `.qpf`  
> Não é necessário abrir ou editar o projeto, apenas **abrir e compilar**.
4. Abra o **Program Device** (*Open Programmer*)
5. Em **Hardware Setup**, selecione **USB-Blaster**
6. Clique em **Start**
7. Aguarde até a barra de progresso chegar em **100%**
8. Retorne ao Quartus
9. Acesse: Tools > In-System Memory Content Editor (ISME)
10. No ISME, clique com o botão direito sobre a memória e selecione **Import File**
11. Importe o arquivo `.hex` correspondente ao `blink.c`, localizado em:  `../software/quartus_blink.hex`
12. Atualize a memória com o arquivo `.hex`
13. No projeto `gpio.qpf`, o **SW(9)** é *hardcoded* como **reset de hardware**  
 - Quando ativo, ele também acende o **LED(9)**  
 - É recomendado sempre iniciar os testes com o reset de hardware ativo
14. Ative o **SW(9)** e, em seguida, desative-o

**Resultado esperado:**  
O código `blink.c` começará a funcionar. Ele implementa um **contador simples**, que acende os LEDs de acordo com o valor binário correspondente ao contador.

---

## Evoluindo para Sua Própria Aplicação

Após conseguir rodar o `blink.c`, o restante do processo se torna muito mais simples.

Utilize:
- `blink.c`
- Projetos da pasta `../applications`
- Projetos da pasta `../software`

como base para o desenvolvimento da sua aplicação.

Evite começar diretamente com a aplicação completa.  
Implemente o projeto por etapas, aumentando a complexidade gradualmente.

Exemplo:
1. Implemente uma fechadura de **1 dígito**
- Um LED de acerto
- Um LED de erro
2. Após fazer 1 funcionar, adicione o display **HEX0**
3. Após fazer 2 funcionar, expanda para uma fechadura de **2 dígitos**
4. Continue incrementando a lógica até chegar na aplicação final

---

## Considerações Finais

- Teste cada etapa antes de avançar
- Evolua o projeto aos poucos
- Não pule passos

Boa sorte e bom desenvolvimento!
