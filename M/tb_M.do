#Cria Biblioteca
vlib work

#Compila Projeto
vcom M_types.vhd
vcom M.vhd
vcom tb_M.vhd

#Simula
vsim -t ns work.tb_M

#Mosta forma de onda
view wave

#Adiciona ondas específicas
#radix: binary, hex, dec
#label: nome da forma de onda

#------------------------------------------------------------------------------------------
add wave -radix binary -label clock_50_0_logic /clock_50_0_logic

#------------------------------------------------------------------------------------------
add wave -radix dec -label a_integer /a_integer
add wave -radix dec -label b_integer /b_integer
add wave -radix dec -label M_data_out_integer /M_data_out_integer
add wave -radix bin -label code_logic_vector /code_logic_vector
#------------------------------------------------------------------------------------------
run 100ns

wave zoomfull
write wave wave.pss