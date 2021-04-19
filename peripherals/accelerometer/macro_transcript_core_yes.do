
vlib work

# softcore
vcom ../../memory/iram_quartus.vhd
vcom ../../memory/dmemory.vhd
vcom ../../alu/alu_types.vhd
vcom ../../alu/alu.vhd
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

# accelerometer
vcom spi_slave.vhd
vcom spi_master.vhd
vcom accelerometer_adxl345.vhd
vcom accel_bus_tb.vhd

# testbench accelerometer
vcom testbench_core_yes.vhd
vsim -t ns work.e_testbench

view wave

# ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
add wave -height 15 -divider "basic"
add wave -radix binary -label clk	/clk
add wave -radix binary -label rst	/rst

# ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
add wave -height 15 -divider "Instruction Memory"
add wave -label iAddr -radix hex /address
add wave -label iWord -radix hex idata
add wave -label decoded -radix ASCII /debugString

# ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
add wave -height 15 -divider "PC and Ctrl Targers"
add wave -radix hex -label pc 			/e_softcore/pc
add wave -radix hex -label jal_target 	/e_softcore/jal_target
add wave -radix hex -label jalr_target 	/e_softcore/jalr_target
add wave -label branch_cmp 				/e_softcore/branch_cmp

# ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
add wave -height 15 -divider "Iregister debug"
add wave -label opcode  /e_softcore/opcodes 
add wave -label rd /e_softcore/rd   
add wave -label rs1 /e_softcore/rs1
add wave -label rs2 /e_softcore/rs2
add wave -label imm_i /e_softcore/imm_i
add wave -label imm_s /e_softcore/imm_s 
add wave -label imm_b /e_softcore/imm_b
add wave -label imm_u /e_softcore/imm_u
add wave -label imm_j /e_softcore/imm_j

# ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
add wave -height 15 -divider "Register file debug"
add wave -label registers -radix hex /e_softcore/registers/ram
add wave -label w_ena 	/e_softcore/rf_w_ena
add wave -label w_data -radix hex	/e_softcore/rw_data
add wave -label r1_data -radix hex /e_softcore/rs1_data
add wave -label r2_data -radix hex /e_softcore/rs2_data
add wave -label states /e_softcore/decoder0/state

# ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
add wave -height 15 -divider "Data memory debug"
add wave -label daddr -radix hex /e_softcore/memAddrTypeSBlock/addr
add wave -label fsm_data -radix hex /e_data_memory/fsm_data
add wave -label ram_data -radix hex /e_data_memory/ram_data
add wave -label mState /e_data_memory/state
add wave -label fsm_we /e_data_memory/fsm_we
add wave -label ddata_r_mem -radix hex /e_data_memory/q
add wave -label datamemory -radix hex /e_data_memory/ram_block

# ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
add wave -height 15 -divider "Data bus"
add wave -label daddress -radix hex /daddress
add wave -label ddata_r -radix hex 	/ddata_r
add wave -label ddata_w -radix hex 	/ddata_w
add wave -label dmask -radix bin /dmask
add wave -label dcsel 	/dcsel
add wave -label d_we 	/d_we
add wave -label d_rd 	/d_rd

# ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
add wave -height 15 -divider "Input/Output SIM"
add wave -label LEDR -radix hex /LEDR

# ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
add wave -height 20 -divider "Accelerometer ( ADXL345 )"
add wave -radix unsigned -label state 	 	/e_accel_bs/e_accelerometer/state
add wave -radix hex  -label  buf_Tx      	/e_accel_bs/e_accelerometer/spi_tx_data
add wave -radix hex  -label  buf_Rx      	/e_accel_bs/e_accelerometer/spi_rx_data
add wave -radix hex  -label  axe_x      	/acceleration_x
add wave -radix hex  -label  axe_y      	/acceleration_y
add wave -radix hex  -label  axe_z      	/acceleration_z

run 50 us