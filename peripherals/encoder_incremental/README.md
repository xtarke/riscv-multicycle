**Instituto Federal de Santa Catarina - IFSC/Florianópolis**

**Aluna:** Greicili dos Santos Ferreira

**Unidade Curricular:** Dispositivos lógicos-progrmáveis


# **Medição da velocidade com encoder incremental**

A ideia do projeto é apresentar a velocidade de rotação (RPM) de um motor e apresentá-la, em hexadecimal, nos displays de 7 segmentos do kit DE10-Lite. O motor utilizado é apresentado na imagem abaixo:


<img width="877" height="414" alt="image" src="https://github.com/user-attachments/assets/dcdff187-1814-4d42-b8c3-8ffc06fdd709" />


**Pinagem:**

1) M1 Motor (GND) - Vermelho
2) GND Encoder - Preto
3) Encoder A phase - Amarelo
4) Encoder B phase - Verde
5) 3.3V Encoder - Azul
6) M1 Motor (+) - Branco

O PPR (pulsos por rotação) do encoder é de , aproximadamente, 412 pulsos por volta.

---

**Cálculo velocidade:**

Para calcular a velocidade é necessário:
1) Intervalo de tempo de contagem, definido no projeto como sendo 100ms.
2) Realizar a contagem dos pulsos.
3) Saber o PPR do encoder.

Utilizando a fórmula abaixo, é possível calcular a velocidade de rotação do motor:

<img width="371" height="85" alt="image" src="https://github.com/user-attachments/assets/eee5975f-da1d-4cd8-a13e-d23c4b788906" />

O sentido de rotação é obtido ao analisar o valor de B na borda de subida do sinal A:
- Se B=0: sentido horário.
- Se B=1: sentido anti-horário.

  <img width="489" height="272" alt="image" src="https://github.com/user-attachments/assets/dfe8f7e2-b2f9-4ea9-b657-f9577cddfb81" />


## **Implementação em VHDL**

### **Portas da entidade encoder:**
- `clk`: Sinal de clock de 10Hz, que serve como TIMMER para a contagem dos pulsos (foi gerado com o divisor de clock e o PLL no clock de 10MHz).
- `aclr_n`: Sinal para o reset do bloco, sendo ativado em nível lógico baixo.
- `A`: Sinal do encoder para a contagem dos pulsos.
- `B`: Sinal do encoder para verificar o sentido de rotação.
- `segs_a`: Apresentar velocidade bits[3   0]
- `segs_b`: Apresenta velocidade bits[7   4]
- `segs_c`: Apresenta velocidade bits[11  8]
- `segs_d`: Apresenta velocidade bits[15 12]
- `segs_e`: Apresenta o sentido de rotação: Apagado (horário) | Sinal negativo (anti-horário)

### **Solução do problema de ter a operação de divisão:**
O uso da operação de divisão em VHDL não é recomendada, portanto, foi necessário encontrar uma solução evitar a divisão.
Na equação do cálculo da velocidade, temos 3 componentes constantes: frequência_timmer, 60 e PPR. Associando esse componentes, como mostrado abaixo, obtemos um resultado que poderá ser multiplicado com a contagem de pulsos. 

<img width="588" height="112" alt="image" src="https://github.com/user-attachments/assets/92873271-64b1-47e4-9a8f-b8c21031c0a4" />

Porém, todo número em ponto flutuante, em VHDL, é arredondado para baixo e, consequentemente, teríamos uma multiplicação por 1, o que não é o desejado. Para resolver esse problema, esse resultado será multiplicado por 10. Essa constante é chamada de **multiplicador** no código.

<img width="226" height="42" alt="image" src="https://github.com/user-attachments/assets/847c8ed6-0e9c-4697-9a75-45da8596001b" />

Deste modo, a velocidade mostrada será 10x maior e apresentará um dígito de precisão.

### **Resultado da simulação no ModelSim:**

Abaixo consta o resultado da simulação com o modelsim. 

No testebench foi gerado os seguintes sinais:
- `Clk:` Obtido do divisor de clock da frequência de 1MHz para 10Hz.
- `aclr_n:` sinal de reset.
- `Sinal de A:` Trem de pulsos com frequência de 1kHz, deste modo, o resultado da contagem dos pulsos é 100, considerando a frequência de 10Hz do Timmer.
- `Sinal de B:` Trem de pulsos com frequência de 1kHz, defasado de 90° do sinal A.
  
<img width="794" height="239" alt="image" src="https://github.com/user-attachments/assets/fdf00bda-ce1c-46af-8553-b175bf965aa7" />


No primeiro resultado calculado da velocidade (0292), o reset estava ativo em parte do tempo de contagem, resultando em um valor menor da velocidade, pois com o reset ativo a contagem é nula. No segundo resultado calculado, temos a contagem completa e que é compatível com que foi obtido na implementação da placa (síntese), mostrado abaixo.

### **Resultado na placa:**

<img width="450" height="301" alt="image" src="https://github.com/user-attachments/assets/64c4ade4-cc86-4dc4-8c72-05ee785c146f" />


Convertendo o valor 0x578 para decimal, temos o valor de 1400. Portanto, **a velocidade é 140,0 RPM.**








