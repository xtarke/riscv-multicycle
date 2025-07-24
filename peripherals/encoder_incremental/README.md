# Medição da velocidade com encoder incremental

A ideia do projeto é apresentar a velocidade de rotação (RPM) de um motor e apresentá-la nos displays de 7 segmentos do kit DE10-Lite. O motor utilizado é apresentado na imagem abaixo:


<img width="877" height="414" alt="image" src="https://github.com/user-attachments/assets/dcdff187-1814-4d42-b8c3-8ffc06fdd709" />


Pinagem:

1) M1 Motor (GND) - Vermelho
2) GND Encoder - Preto
3) Encoder A phase - Amarelo
4) Encoder B phase - Verde
5) 3.3V Encoder - Azul
6) M1 Motor (+) - Branco

O PPR (pulsos por rotação) é .

Para calcular a velocidade é necessário:
- Intervalo de tempo de contagem, definido no projeto como sendo 100ms.
- Realizar a contagem dos pulsos.
- Saber o PPR do encoder.

Utilizando a fórmula abaixo, obtem-se a velocidade de rotação do motor:

<img width="371" height="85" alt="image" src="https://github.com/user-attachments/assets/eee5975f-da1d-4cd8-a13e-d23c4b788906" />

O sentido de rotação é obtido ao analisar o valor de B na borda de subida do sinal A:
- Se B=0: sentido horário.
- Se B=1: sentido anti-horário.

  
## Implementação em VHDL

### Portas da entidade encoder:
- `PPR`: Quantidade de pulso por rotação do encoder.
- `clk`: Sinal de clock de 10Hz, que serve como TIMMER para a contagem dos pulsos (foi gerado com o divisor de clock e o PLL na clock de 10MHz).
- `aclr_n`: Sinal para reset do bloco, sendo ativado em nível lógico baixo.
- `A`:
- `B`:
- `segs_a`: Apresenta da velocidade bits[3  0]
- `segs_b`: Apresenta da velocidade bits[7  4]
- `segs_c`: Apresenta da velocidade bits[11 8]
- `segs_d`: Apresenta a sentido de rotação: Apagado (horário) | Sinal negativo (anti-horário)


### Resultado da simulação:

Abaixo consta o resultado da simulação com o modelsim, com a frequência de A estipulada como sendo de 50Hz, deste modo, o número de contagens é de 5, considerando a frequência de 10Hz do Timmer. Na simulação, calculou-se até 6 pois a borda de subida de A coincidiu com a borda de subida do clock, resultando em 3000 pulsos por minuto, definindo a velocidade de 3 RPM, considerando o PPR de 1000. Na prática, a velocidade será de 2 RPM (RPM = 5*10*60/1000 = 2.4, é arredondado para baixo, devido ao tempo de subida do sinal de A e do clock.

<img width="784" height="234" alt="image" src="https://github.com/user-attachments/assets/0b0d582a-69bb-4baf-be58-4ed67c016ffe" />






