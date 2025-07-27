# Animação de Segmentos com Máquina de Estados em VHDL

Este projeto implementa uma **máquina de estados finita (FSM)** em VHDL para animar os LEDs de um display de 7 segmentos (simulado como vetor), controlando o sentido da animação através de uma entrada de direção (`direction`) e a velocidade com um divisor de clock configurável.

## 🔧 Estrutura do Projeto

### 📁 Arquivos Principais

| Arquivo               | Descrição |
|------------------------|-----------|
| `animation_segs.vhd`  | Implementa a máquina de estados que gera a animação dos segmentos. |
| `divisor_clock.vhd`   | Divide o clock de entrada com base na entrada `speed`. |
| `tb_animation_segs.vhd` | Testbench que simula o comportamento da FSM e do divisor. |

---

## ⚙️ Máquina de Estados

A FSM percorre estados que representam padrões nos 8 bits de saída (`segs`), acendendo um bit por vez da esquerda para a direita ou vice-versa, conforme a direção:

```text
Direção = '1' (Direta):    "10000000" → "01000000" → ... → "00000001"
Direção = '0' (Reversa):   "00000001" → "00000010" → ... → "10000000"
