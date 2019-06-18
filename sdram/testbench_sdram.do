# cd C:/Users/Cleissom/eclipse-workspace/riscv-multicycle/sdram

#Cria biblioteca do projeto
vlib work

#compila projeto: todos os aquivo. Ordem é importante
vcom ./tristate.vhd ./cpu_typedef_package.vhdl sdram_controller.vhd ./sim/mti_pkg.vhd ./sim/mt48lc8m16a2.vhd testbench_sdram.vhd

#Simula
vsim -t ps work.testbench_sdram

#Mosta forma de onda
view wave

#Adiciona ondas específicas
# -radix: binary, hex, dec
# -label: nome da forma de onda
add wave -label clk /clk
add wave -label clk2 /clk2
add wave -label byteenable /byteenable
add wave -label chipselect /chipselect
add wave -label address /address
add wave -label reset /reset
add wave -label reset_req /reset_req
add wave -label write /write
add wave -label read /read
add wave -label writedata /writedata
add wave -label readdata /readdata


add wave -radix unsigned -label DRAM_ADDR /DRAM_ADDR
add wave -radix unsigned -label DRAM_CS_N /DRAM_CS_N
add wave -radix unsigned -label DRAM_CKE /DRAM_CKE
add wave -radix unsigned -label DRAM_RAS_N /DRAM_RAS_N
add wave -radix unsigned -label DRAM_CAS_N /DRAM_CAS_N    
add wave -radix unsigned -label DRAM_WE_N /DRAM_WE_N    
add wave -radix unsigned -label DRAM_DQ /DRAM_DQ

add wave -radix unsigned -label mem_state /sdram_controller_0/mem_state

#Simula até um 500ns
run 1us

wave zoomfull
write wave wave.ps