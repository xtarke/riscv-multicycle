vdel -lib work -all
vlib work

# Core modules
vcom ../../memory/iram_quartus.vhd
vcom ../../memory/dmemory.vhd
vcom ../../memory/instructionbusmux.vhd
vcom ../../memory/databusmux.vhd
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

# CAN peripheral
vcom can_pkg.vhd
vcom register_map.vhd
vcom can_engine.vhd
vcom can_fsm.vhd
vcom can_top.vhd

# Testbench (na raiz do projeto)
vcom tb_riscv.vhd

vsim -voptargs="+acc" work.tb_riscv

view wave
add wave -radix binary clk rst
add wave -height 15 -divider "Core"
add wave -radix hex iaddress
add wave -radix hex idata
add wave -radix ascii debugString
add wave -height 15 -divider "Data Bus"
add wave d_we dcsel d_sig
add wave -radix hex daddress ddata_w ddata_r dmask
add wave -height 15 -divider "CAN"
add wave can_wr_en can_tx can_rx
add wave -radix hex can_reg_addr
add wave -height 15 -divider "CAN Internal"
add wave -label can_clk_out     /can_inst/clk_out
add wave -label can_fsm_state   -radix hex  /can_inst/current_state
add wave -label state_name /can_inst/can_fsm_inst/current_state
add wave tx_done
add wave -label baud_reg        -radix hex  /can_inst/baud_reg_out
add wave -label txb0ctrl_reg    -radix hex  /can_inst/txb0ctrl_out
add wave -label txb0sidh_reg    -radix hex  /can_inst/txb0sidh_out
add wave -label txb0sidl_reg    -radix hex  /can_inst/txb0sidl_out
add wave -label txb0dlc_reg     -radix hex  /can_inst/txb0dlc_out
add wave -label txb0d0          -radix hex  /can_inst/r_TXB0Dn(0)
add wave -label txb0d1          -radix hex  /can_inst/r_TXB0Dn(1)
#add wave  -label tmp  -radix hex tmp
#add wave -label crc_reg   -radix hex  /can_inst/can_engine_inst/crc_reg
run 2 ms
wave zoomfull