#Cria biblioteca do projeto
vlib work

#compila projeto: todos os aquivo. Ordem é importante
vcom block_controller.vhd block_reset.vhd draw_rect.vhd block_clean.vhd generator.vhd tb_generator.vhd

#Simula (work é o diretorio, testbench é o nome da entity)
vsim -t ns work.testbench_generator

#Mosta forma de onda
view wave

#Adiciona ondas específicas
# -radix: binary, hex, dec
# -label: nome da forma de onda

add wave -height 15 -divider "GENERATOR"

add wave -radix binary 	-label clk 		/clk
add wave -radix binary  -label mem_full /mem_full
add wave -radix binary  -label mem_init /mem_init
add wave -radix hex  	-label input_a 	/input_a
add wave -radix hex  	-label input_b	/input_b
add wave -radix hex  	-label input_c	/input_c
add wave -radix binary  -label rst 		/rst
add wave -radix hex  	-label output 	/output

#Como mostrar sinais internos do processo
add wave -radix hex		-label sel	 	/dut/sel
add wave -radix bin		-label completed /dut/mux_completed
add wave -radix binary  -label enable 	/dut/enable

add wave -height 15 -divider "CONTROLLER"
add wave -radix dec		-label start 	/dut/controller_inst/start
add wave -radix hex  	-label cmd 		/dut/controller_inst/cmd
add wave -radix hex  	-label state	/dut/controller_inst/state
add wave -radix hex  	-label ready	/dut/controller_inst/ready

add wave -height 15 -divider "RESET"
add wave -radix hex  	-label state_R	/dut/reset_inst/state

add wave -height 15 -divider "CLEAN"
add wave -radix hex  	-label state_C	/dut/clean_inst/state
add wave -radix dec  	-label count	/dut/clean_inst/state_transation/count_size

#Simula até um 50ns
run 500us

wave zoomfull
write wave wave.ps
