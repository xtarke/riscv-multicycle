if {! [ file exists work ] } { 
	echo "criando biblioteca WORK..."
	vlib work
	echo " "
} else {
	echo "apagando biblioteca WORK..."
	vdel -all
	echo "recriando biblioteca WORK..."
	vlib work
	echo " "
}

## comando de compilação.
vcom ./divisor_clock.vhd
vcom ./pwm_gen.vhd
vcom ./fsm.vhd
vcom ./testbench.vhd

## comando de simulação
vsim -voptargs=+acc -wlfdeleteonquit work.tb

## adição dos sinais na forma de onda.
add wave sim:/*
add wave -divider "sinais do duv"
add wave sim:/duv/*



## execução da simulação.
run 3 sec
