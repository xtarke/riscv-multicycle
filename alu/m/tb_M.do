#Cria Biblioteca
vlib work

#Compila Projeto
vcom division_functions.vhd
vcom quick_naive.vhd
vcom quick_clz.vhd
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
add wave -radix bin -label clock /clock
add wave -radix bin -label reset /reset
add wave -radix dec -label a_integer /a_integer
add wave -radix dec -label b_integer /b_integer
add wave -radix dec -label M_data_out_integer /M_data_out_integer
add wave -radix bin -label code_logic_vector /code_logic_vector

add wave -radix unsigned -label quotient_sig /M_vhd/quotient_sig

#------------------------------------------------------------------------------------------
run 400ns

wave zoomfull
write wave wave.pss
