# Cria biblioteca do projeto
vlib work

# Compila projeto: todos os aquivo. Ordem é importante
# Sempre colocar todos os arquivos .vdh aqui em ordem
vcom led_tx.vhd
vcom tb_noise.vhd

# Simula
# Sempre mudar a entity aqui caso o nome da entity e arquivo forem diferentes
# ns é a resolução, portanto quanto < escala de tempo + lento fica
vsim -voptargs="+acc" -t ns work.tb_noise

# Mostra forma de onda    
view wave

# Adiciona ondas específicas
# -radix: binary, hex, dec
# -label: nome da forma de onda
# Adicionar aqui os nomes das labels usadas no led_tx.vdh 
add wave -radix binary -label clk /clk
add wave -radix binary -label rst /rst
add wave -radix binary -label led_out /led_out
add wave -radix binary -label sensor_out /sensor_out

# Simula até 500ns
run 500us

wave zoomfull
write wave wave.ps
