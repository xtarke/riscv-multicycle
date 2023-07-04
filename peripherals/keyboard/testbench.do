# ============================================================================
# Name        : testbench.do
# Author      : Renan Augusto Starke
# Version     : 0.1
# Copyright   : Renan, Departamento de Eletrônica, Florianópolis, IFSC
# Description : Exemplo de script de compilação ModelSim
# ==============================================a==============================

#Cria biblioteca do projeto
vlib work


#compila projeto: todos os aquivo. Ordem é importante
vcom key.vhd testbench.vhd
vcom ../../memory/iram_quartus.vhd
vcom ../../memory/dmemory.vhd
vcom ../../memory/instructionbusmux.vhd
vcom ../..//memory/databusmux.vhd
vcom ../../memory/iodatabusmux.vhd
vcom ../../alu/alu_types.vhd
vcom ../../alu/alu.vhd
vcom ../../alu/m/division_functions.vhd
vcom ../../alu/m/quick_naive.vhd
vcom ../../alu/m/M_types.vhd
vcom ../../alu/m/M.vhd
vcom ../../decoder/decoder_types.vhd
vcom ../../decoder/iregister.vhd
vcom ../../decoder/decoder.vhd
vcom ../../registers/register_file.vhd
vcom ../../core/csr.vhd
vcom ../../core/core.vhd
vcom ../../core/txt_util.vhdl
vcom ../../core/trace_debug.vhd

#Simula (work é o diretorio, testbench é o nome da entity)
vsim -voptargs="+acc" -t ns work.testbench

#Mosta forma de onda
view wave

#Adiciona ondas específicas
# -radix: binary, hex, dec
# -label: nome da forma de onda

add wave -label clk -radix binary /clk
add wave -label rst -radix binary /rst
add wave -label linhas -radix binary /linhas
add wave -label colunas -radix binary /colunas
add wave -label ddata_r -radix dec  /ddata_r
add wave -label d_rd    /d_rd
add wave -label estado -radix binary /keyboard/state


run 1000000 ns

wave zoomfull
write wave wave.ps
