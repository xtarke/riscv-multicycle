## Fechadura Digital

Aluno: Marcelo Zampieri Pereira da Silva

## Descrição Geral

Este projeto implementa uma fechadura digital simples em um sistema embarcado baseado em RISC-V, utilizando switches, LEDs e displays de 7 segmentos para interação com o usuário.

O usuário insere dois dígitos usando os switches 3 downto 0 (SW3 a SW0) e confirma cada dígito pressionando o botão ENTER.  


O sistema compara os dígitos com uma*senha fixa e indica sucesso ou erro através de LEDs.  


Após um número máximo de tentativas erradas, o sistema entra em modo bloqueado.

---

## Hardware Utilizado

- **Switches (INBUS)**
  - SW `0–3` → valor do dígito (0 a 15);
  - SW `4` → botão ENTER;
  - SW `7` → botão RESET de software, feito em C utilizando uma mask;
  - SW `9` → botão RESET de hardware, programado direto no FPGA utilizando o arquivo .qpf.

- **LEDs (OUTBUS)**
  
  - LED `0-3` → LEDs de aviso. São ligados quando o SW equivalente está em '1' (SW0 liga LED0), utilizado para demonstrar o número binário que está atualmente sendo digitado;
  - LED `5` → LED de acerto;
  - LED `6` → LED de erro;
  - LED `9` → LED de reset. Ligado quando o reset de hardware é ativado.

- **Display HEX**
  - `HEX0` → mostra o número de tentativas restantes

---

## Configurações do Sistema

```c
#define PASSWORD_D1 3
#define PASSWORD_D2 5
#define MAX_TRIES   3

