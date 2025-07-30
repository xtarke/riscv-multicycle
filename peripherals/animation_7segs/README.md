# Animação de Segmentos com Máquina de Estados em VHDL

Este projeto implementa uma **máquina de estados finita (FSM)** em VHDL para animar os LEDs de um display de 7 segmentos (simulado como vetor), controlando o sentido da animação através de uma entrada de direção (`direction`) e a velocidade com um divisor de clock configurável.

## 📁 Arquivos do Projeto

| Arquivo               | Descrição |
|------------------------|-----------|
| `seven_segs.vhd`          | Converte o vetor de 8 bits para controle dos segmentos de um display.|
| `clock_divider.vhd`       | Divide o clock de entrada com base na entrada `speed`. |
| `fsm_animation_segs.vhd`  | Implementa a máquina de estados que gera a animação dos segmentos. |
| `animation_segs.vhd`      | Módulo top-level que integra o divisor de clock e a FSM de animação. |
| `tb_animation_segs.vhd`   | Testbench que simula o comportamento da FSM com controle de direção e velocidade. |
| `tb.do`   | Script do ModelSim que compila os arquivos VHDL do projeto, roda a simulação do testbench `tb_animation_segs` e exibe os sinais. |

---

## ⚙️ Organização do projeto

Os blocos e sinais estão conectados como ilustra abaixo:

![Diagrama de Blocos ](media/diagrama_blocos.png)

A FSM possui estados definidos para alternar os bits acesos em `segs`, com comportamento dependente do sinal `direction` e o controle de velocidade é feito por um contador interno que depende do valor do vetor `speed`.


| Sinal       | Direção | Tipo                           | Descrição                                                                 |
|------------|-----------|--------------------------------|-----------------------------------------------------------------------------|
| `clk`      | in        | `std_logic`                    | Clock principal do sistema                                                 |
| `direction`| in        | `std_logic`                    | Direção da animação ('0' para esquerda, '1' para direita)                  |
| `rst`      | in        | `std_logic`                    | Sinal de reset síncrono para reiniciar a animação                          |
| `speed`    | in        | `std_logic_vector(1 downto 0)` | Seleção da velocidade (2 bits = 4 velocidades possíveis)                   |
| `segs`     | out       | `std_logic_vector(7 downto 0)` | Saída para os segmentos do display (ativo baixo ou alto, depende do hardware) |



A FSM percorre estados que representam padrões nos 8 bits de saída (`segs`), acendendo um bit por vez da esquerda para a direita ou vice-versa, conforme a direção:

```text
Direção = '1':   A → AB → ... → FA
Direção = '0':   A → FA → ... → AB
```

![Estados da Máquina de Estados](media/fsm_states.png)

## 🔁 Simulação

A simulação foi realizada no ModelSim com testes (`tb_animation_segs.vhd`), que gera estímulos para `clk`, `rst`, `speed `e `direction`.

### 📷 Screenshot da simulação

![Simulação no ModelSim](media/simulacao_modelsim.png)

## Síntese e gravação do projeto

| Arquivo       | Descrição|
|------------|-----------|
| `de10_lite.vhd` |	Arquivo top-level do projeto, conecta todos os blocos à placa|
|`clk.vhd `|PLL para gerar clock estável a partir do ADC_CLK_10|


1. Abra o projeto `de10_lite.qpf` no Quartus.
2. Compile o projeto *Processing > Start Compilation*.
3. Grave o arquivo na placa em *Tools > Programmer*.
4. Use as chaves SW7 (reset), SW6 (direção) e SW1-SW0 (velocidade da animação).


### GIF do funcionamento

![GIF da animação](media/animation_gif.gif)


