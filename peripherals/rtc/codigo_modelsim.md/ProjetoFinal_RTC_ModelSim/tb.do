
# ============================================================================
# Name        : tb.do
# Author      : Thais Silva Lisatchok
# Version     : 08/07/2025
# Description : Exemplo de script de compilação ModelSim para o rtc, 
# com base nos arquivos disponibilizados pelo professor.
# ============================================================================

# Cria a biblioteca do projeto
vlib work

# Compila os arquivos VHDL (rtc.vhd e testbench.vhd)
vcom bin_to_bcd.vhd
vcom rtc.vhd
vcom testbench.vhd


# Executa a simulação (work é o diretório, testbench é o nome da entidade de teste)
vsim -voptargs="+acc" -t ns work.testbench

# Mostra a forma de onda na janela de visualização
view wave

# Adiciona as ondas específicas de cada sinal para visualização
# -radix: uns (unsigned), bin (binário), hex (hexadecimal), dec (decimal)
# -label: nome da onda, que será exibido na forma de onda

# Ondas específicas do RTC 
add wave -radix uns /testbench/clk
add wave -radix uns /testbench/rst
add wave -radix uns /testbench/sec
add wave -radix uns /testbench/min
add wave -radix uns /testbench/hour
add wave -radix uns /testbench/day
add wave -radix uns /testbench/month
add wave -radix uns /testbench/year

# Simula até 1300ns (ajustar conforme necessário)
run 3000ns

# Realiza um zoom nas ondas para visualizar completamente
wave zoomfull

# Salva a forma de onda em um arquivo de formato .ps
write wave wave.ps
