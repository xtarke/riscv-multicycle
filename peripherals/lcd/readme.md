# Controlador LCD Nokia5110

Hardware para controle de inicialização e escrita no LCD Nokia5110.
<p align="left">
    <img width="20%" height="20%" src="rtl.png">
</p>

# Pinagem
Entradas:
- `clk`: Clock do controlador. Opera internamente na borda de subida.
- `reset`: Reset do controlador. Opera em lógica inversa (0 ativa o reset).
- `char`: Código ASCII do caractere a ser printado.
  
Saídas:
- `ce`: Quando ce = 0, a transmissão serial é iniciada. Deve-se manter ce = 0 durante a transmissão de comando ou caractere ao LCD, pois durante ce = 1, os pulsos do clock da serial       são ignorados pelo LCD.
- `dc`: Indica se o byte enviado ao LCD é um comando (dc = 0) ou caracetere (dc = 1).
- `din`: Bit transmitido pela serial. Lido pelo LCD na borda de subida do clock da serial (serial_clk).
- `light`: Iluminação de fundo.
- `rst`: rst = 0 reseta o LCD. Deve ser aplicado sempre para inicializar corretamente, mantendo-o durante pelo menos 100 us.
- `serial_clk`: Clock da serial (frequência máxima de 4 MHz).

# Funcionamento
Sequência de inicialização:
1. Reset
2. Set Command Type
3. Set Constrast
4. Set Temperature Coefficient
5. Set Bias Mode
6. Send 0x20
7. Set Control Mode
8. Clear Display
