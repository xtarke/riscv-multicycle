#******************************************************************************
#                                                                             *
#                  Copyright (C) 2019 IFSC                                    *
#                                                                             *
#                                                                             *
# All information provided herein is provided on an "as is" basis,            *
# without warranty of any kind.                                               *
#                                                                             *
# File Name: testbench.do          						    				  *
#                                                                             *
# Function: riscv muticycle simulation script		  	                 	  *
#                                                                             *
# REVISION HISTORY:                                                           *
#  Revision 0.1.0    08/01/2018 - Initial Revision                            *
#******************************************************************************

vlib work
# vcom ./memory/imemory.vhd
vcom ./memory/imemory_load.vhd
vcom ./sint/iram_quartus.vhd
vcom ./memory/dmemory.vhd
vcom ./alu/alu_types.vhd
vcom ./alu/alu.vhd
vcom ./M/M_types.vhd
vcom ./M/M.vhd
vcom ./decoder/decoder_types.vhd
vcom ./decoder/iregister.vhd
vcom ./decoder/decoder.vhd
vcom ./registers/register_file.vhd
vcom ./uart/uart.vhd
vcom ./core/core.vhd
vcom ./core/txt_util.vhdl
vcom ./core/trace_debug.vhd
vcom ./vga/vga_controller.vhd ./vga/vga_buffer.vhd
vcom ./sdram/sim/mti_pkg.vhd ./sdram/sim/mt48lc8m16a2.vhd ./sdram/sdram_controller.vhd 
vcom ./core/testbench.vhd
vcom ./spi/SPI.vhd

vsim -t ns work.testbench

view wave
add wave -radix binary 	/clk
add wave -radix binary 	/rst
add wave -height 15 -divider "Instruction Memory"
add wave -label iAddr -radix hex /address
add wave -label iWord -radix hex idata
add wave -label decoded -radix ASCII /debugString
# add wave /debugString
# add wave -radix hex /imem/RAM
# add wave -radix hex /q

add wave -height 15 -divider "PC and Ctrl Targers"
# add wave -radix hex -label pc 			/myRiscv/pc
# add wave -radix hex -label jal_target 	/myRiscv/jal_target
# add wave -radix hex -label jalr_target 	/myRiscv/jalr_target
# add wave -label branch_cmp 				/myRiscv/branch_cmp

add wave -height 15 -divider "Iregister debug"
add wave -label opcode  /myRiscv/opcodes 
add wave -label rd /myRiscv/rd   
add wave -label rs1 /myRiscv/rs1
add wave -label rs2 /myRiscv/rs2
add wave -label imm_i /myRiscv/imm_i
add wave -label imm_s /myRiscv/imm_s 
add wave -label imm_b /myRiscv/imm_b
add wave -label imm_u /myRiscv/imm_u
add wave -label imm_j /myRiscv/imm_j


add wave -height 15 -divider "Register file debug"
 add wave -label registers -radix hex /myRiscv/registers/ram
 add wave -label w_ena 	/myRiscv/rf_w_ena
 add wave -label w_data 	/myRiscv/rw_data
 add wave -label r1_data -radix hex /myRiscv/rs1_data
 add wave -label r2_data -radix hex /myRiscv/rs2_data

# decoder debug
add wave -label states /myRiscv/decoder0/state

# add wave -height 15 -divider "Alu debug"
# add wave -label aluData /myRiscv/alu_data
#add wave -label aluOut 	/myRiscv/alu_out

add wave -height 15 -divider "Data memory debug"
add wave -label daddr -radix hex /myRiscv/memAddrTypeSBlock/addr
add wave -label fsm_data -radix hex /dmem/fsm_data
add wave -label ram_data -radix hex /dmem/ram_data
add wave -label mState /dmem/state
add wave -label fsm_we /dmem/fsm_we

add wave -height 15 -divider "Data bus"
add wave -label daddress -radix hex /daddress
add wave -label ddata_r -radix hex 	/ddata_r
add wave -label ddata_w -radix hex 	/ddata_w
add wave -label dmask -radix bin /dmask
add wave -label dcsel 	/dcsel
add wave -label d_we 	/d_we
add wave -label d_rd 	/d_rd

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
add wave -label DRAM_BA -radix hex 		/DRAM_BA
add wave -label DRAM_RAS_N -radix hex 		/DRAM_RAS_N
add wave -radix binary 	/clk_sdram_ctrl

add wave -height 15 -divider "VGA"
add wave -label clk_vga		 			/clk_vga
add wave -label VGA_HS	 				/VGA_HS
add wave -label VGA_VS	 				/VGA_VS
add wave -label vga_addr 	-radix hex 	/vga_addr

add wave -height 15 -divider "VGA Buffer"
add wave -label VGA_R 		-radix hex 	/VGA_R
add wave -label VGA_G 		-radix hex 	/VGA_G
add wave -label VGA_B 		-radix hex 	/VGA_B
add wave -label buffer_to_sdram_addr 	-radix hex 	/buffer_to_sdram_addr
add wave -label sdram_read 	-radix hex 	/sdram_read
add wave -label vga_data_read 	-radix hex 	/vga_data_read
add wave -label vga_buffer 	-radix hex 	/vga_buffer/memory


add wave -height 15 -divider "UART"
add wave -label clk_baud -radix hex /clk_baud
add wave -radix binary -label state_tx /uart_inst/state_tx
add wave -label csel -radix bin /uart_inst/csel
add wave -label data_in -radix hex /data_in
add wave -radix binary -label to_tx /uart_inst/to_tx
add wave -label tx -radix bin /tx
add wave -label tx_cmp -radix bin /tx_cmp

add wave -height 15 -divider "Input/Output SIM"
add wave -label LEDR -radix hex /LEDR
add wave -label ARDUINO_IO -radix hex /ARDUINO_IO

add wave -height 15 -divider "SPI"
add wave -radix hex -label  i_clk       /i_clk
add wave -radix hex -label  i_rst       /i_rst
add wave -radix hex -label  i_tx_start  /i_tx_start
add wave -radix hex -label  i_data      /i_data
add wave -radix hex -label  i_miso      /i_miso
add wave -radix hex -label  o_data      /o_data
add wave -radix hex -label  o_tx_end    /o_tx_end
add wave -radix hex -label  o_sclk      /o_sclk
add wave -radix hex -label  o_ss        /o_ss
add wave -radix hex -label  o_mosi      /o_mosi

run 950000 ns
