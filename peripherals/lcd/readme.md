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
1. __Reset__
2. __Set Command Type__ : din = 00100PVH  
- `P = 0`: Chipe ativo 
- `P = 1`: Modo power-down  
- `V = 0`: Endereçamento horizontal
- `V = 1`: Endereçamento Vertical 
- `H = 0`: Set de instruções básico
- `H = 1`: Set de instruções estendido
3. __Set Constrast__ : din = 1011ABCD
- `ABCD` = 0000 até 1111 (mais claro até o mais escuro)
4. __Set Temperature Coefficient__ : din = 000001AB
- `AB` = 00 até 11
5. __Set Bias Mode__ : din = 00010ABC
- `ABC` = 000 até FFF
6. __Send 0x20__ : Necessário enviar 0x20 antes de alterar o control mode.
7. __Set Control Mode__ : din = 000011AB
- `AB` = 00: modo normal
- `AB` = 01: modo inverso
8. __Clear Display__
