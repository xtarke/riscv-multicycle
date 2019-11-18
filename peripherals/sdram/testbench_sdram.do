# cd C:/Users/Cleissom/eclipse-workspace/riscv-multicycle/sdram

#Cria biblioteca do projeto
vlib work

#compila projeto: todos os aquivo. Ordem é importante
vcom sdram_controller.vhd ./sim/mti_pkg.vhd ./sim/mt48lc8m16a2.vhd testbench_sdram.vhd

#Simula
vsim -t ps work.testbench_sdram

#Mosta forma de onda
view wave

add wave -height 15 -divider "SDRAM"
add wave -label clk_sdram		 		/clk_sdram
add wave -label chipselect_sdram	 	/chipselect_sdram
add wave -label sdram_addr -radix hex 	/sdram_addr
add wave -label DRAM_ADDR -radix hex 	/DRAM_ADDR
add wave -label d_we		 			/d_we
add wave -label sdram_d_rd		 		/sdram_d_rd
add wave -label ddata_w -radix hex 		/ddata_w
add wave -label sdram_read -radix hex 	/sdram_read
add wave -label DRAM_DQ -radix hex 		/DRAM_DQ
add wave -label burst		 			/burst
add wave -label mem_state 				/sdram_controller/mem_state
add wave -label d_read 				/sdram_controller/d_read


add wave -radix unsigned -label DRAM_ADDR /DRAM_ADDR
add wave -radix unsigned -label DRAM_CS_N /DRAM_CS_N
add wave -radix unsigned -label DRAM_CKE /DRAM_CKE
add wave -radix unsigned -label DRAM_RAS_N /DRAM_RAS_N
add wave -radix unsigned -label DRAM_CAS_N /DRAM_CAS_N    
add wave -radix unsigned -label DRAM_WE_N /DRAM_WE_N    
add wave -radix hex -label DRAM_DQ /DRAM_DQ

#Simula até um 500ns
run 3500ns

wave zoomfull
write wave wave.ps