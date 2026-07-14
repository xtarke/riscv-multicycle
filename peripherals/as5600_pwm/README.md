# Projeto AS5600 Integrado com Softcore RISC-V (Placa DE10-Lite)

Este documento descreve toda a arquitetura, montagem e fluxo de execução do projeto de integração do sensor magnético de posição absoluta AS5600 em um ambiente FPGA contendo um processador RISC-V.

---

## 1. Visão Geral do Projeto

O objetivo do projeto é medir o ângulo de rotação de um ímã utilizando o sensor **AS5600** através de sua interface **PWM** e exibir o ângulo (0 a 360°) nos displays de 7 segmentos da placa FPGA Intel MAX 10 (DE10-Lite).

O sistema conta com um **Modo Potenciômetro (Multi-voltas)**: ao ligar a chave `SW0`, o processador começa a contar as voltas acumuladas, agindo como um potenciômetro que vai do valor 0 ao 100 após duas voltas completas (720 graus).

---

## 2. Arquitetura do Sistema

O projeto é dividido rigidamente em duas camadas: **Hardware (VHDL)** e **Software (C)**.

### A. Camada de Hardware (VHDL)
O arquivo principal é o `as5600_pwm.vhd`. A FPGA atua medindo sinais físicos em altíssima velocidade.
* **Filtro Anti-Metastabilidade:** Como o sinal do sensor é externo e assíncrono, ele passa por dois Flip-Flops (`pwm_sync_1` e `pwm_sync_2`) para se alinhar perfeitamente com o clock da placa, evitando falhas lógicas.
* **Cronômetros:** O VHDL não calcula ângulos. Ele apenas possui dois cronômetros: um que conta o tempo total do ciclo PWM (`t_period`) e outro que conta o tempo que o sinal fica em nível lógico alto (`t_high`).
* **Comunicação:** O módulo disponibiliza esses tempos no **Slot 22** do barramento de dados do processador.

### B. Camada de Software (C)
O arquivo principal é o `main.c`. Rodando dentro do núcleo RISC-V, o software é o "cérebro" matemático.
* **Memory-Mapped I/O:** O C acessa o Slot 22 físico através dos ponteiros `#define AS5600_T_HIGH` e `AS5600_T_PERIOD` presentes no mapa de memória (`hardware.h`).
* **Matemática do Datasheet:** Com base no manual oficial do AS5600, o sinal PWM tem um quadro de **4351 clocks**, possuindo um cabeçalho obrigatório de **128 clocks**. O software faz a regra de três para converter o tempo lido pela FPGA, subtrai o 128, e converte o restante (limite de 4095 de resolução) em um ângulo de **0 a 360 graus**.
* **Formatação BCD:** Fatiamos o ângulo final com a matemática de resto de divisão (`% 10`) e agrupamos os pedaços com deslocamento de bits (`<< 4`) para enviar a informação correta ao hardware dos displays de 7 segmentos.

---

## 3. Setup Físico (Montagem)

Para que o projeto funcione no mundo real, você precisará de:
1. Uma FPGA **Terasic DE10-Lite**.
2. O módulo do sensor magnético **AS5600**.
3. Um ímã diametral.

**Conexões Básicas dos Pinos:**
* **VDD / VCC:** Ligar no pino de 3.3V ou 5V da DE10-Lite (verifique a versão exata da sua plaquinha do AS5600).
* **GND:** Ligar em qualquer pino GND da FPGA.
* **PWM / OUT:** Ligar no pino de GPIO específico definido pelo seu projeto Quartus (onde o sinal `pwm_in` está mapeado fisicamente, geralmente no cabeçalho Arduino ou GPIO lateral da DE10-Lite).

> [!WARNING]
> **Alinhamento do Ímã:** O ímã diametral deve ser posicionado milimetricamente acima do centro do chip AS5600 (a distância de *airgap* recomendada pelo datasheet é de 0.5 mm a 3 mm). Eixos tortos geram leituras de PWM ruidosas.

---

## 4. Como Compilar e Rodar

Sempre que você alterar o código em C (`main.c`), não é necessário recompilar a FPGA inteira! Siga os passos:

### Passo 1: Compilar o C
Abra o seu terminal Linux/WSL/MSYS2, navegue até a pasta `software/as5600_app/` e rode:
```bash
make clean
make
```
Isso gerará o arquivo atualizado `quartus_main.hex`.

### Passo 2: Gravar na FPGA

**Opção A (A mais rápida - via Terminal / In-System Memory):**
Se a placa já estiver ligada, no mesmo terminal onde deu o `make`, rode:
```bash
make flash
```
*(Isso vai injetar o arquivo `.hex` diretamente na memória RAM da placa pela porta JTAG em poucos segundos, atualizando o C).*

**Opção B (O método clássico - via Intel Quartus):**
1. Abra o projeto principal **`de10_lite.qpf`** (localizado em `sint/de10_lite/`) no software Intel Quartus.
2. Na barra superior, clique em: `Processing` -> `Update Memory Initialization File`.
3. Na barra superior, clique em: `Processing` -> `Start` -> `Start Assembler`.
4. Abra o `Programmer` (Tools -> Programmer), selecione o novo arquivo `.sof` gerado e clique em **Start** para gravar a placa.

---

## 5. Como Testar e Apresentar

Com a placa gravada e o sensor conectado:
1. Gire o ímã suavemente sobre o sensor.
2. Os displays hexagonais da DE10-Lite (HEX1 a HEX3) exibirão o ângulo de **0 a 359**, e o display HEX0 exibirá o símbolo de grau `°`.
3. Levante a **Chave SW0** (primeiro interruptor à direita na placa). Isso aciona o nosso "Modo Potenciômetro".
4. Dê voltas consecutivas com o ímã. O display não irá mais zerar após o 360; ele vai acumular os giros e a tela exibirá uma escala unificada de **0 a 100**, onde 100 só é atingido após você completar exatamente duas voltas (720 graus)!
