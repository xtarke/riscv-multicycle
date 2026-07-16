# ModelSim/Questa macro for the SDRAM controller testbench.
# Run from peripherals/sdram:  vsim -do testbench_sdram.do

# Project library
vlib work

# Compile. Order matters: package and SDRAM model before the DUT and testbench.
vcom sdram_pkg.vhd
vcom ./sim/mti_pkg.vhd ./sim/mt48lc8m16a2.vhd
vcom sdram_controller.vhd
vcom testbench_sdram.vhd

# Elaborate
vsim -t ps work.testbench_sdram

# Waveforms
view wave

add wave -height 15 -divider "User side"
add wave -label clk                   /clk_sdram
add wave -label reset                 /rst
add wave -label chipselect            /chipselect_sdram
add wave -label address    -radix hex /sdram_addr
add wave -label write                 /d_we
add wave -label read                  /sdram_d_rd
add wave -label write_data -radix hex /ddata_w
add wave -label read_data  -radix hex /sdram_read
add wave -label read_valid_count      /read_valid_count
add wave -label waitrequest           /waitrequest

add wave -height 15 -divider "Controller FSM"
add wave -label mem_state /dut/mem_state
add wave -label idx       /dut/idx
add wave -label d_read    /dut/d_read
add wave -label d_write   /dut/d_write

add wave -height 15 -divider "SDRAM bus"
add wave -label DRAM_ADDR  -radix hex /DRAM_ADDR
add wave -label DRAM_BA    -radix hex /DRAM_BA
add wave -label DRAM_CS_N              /DRAM_CS_N
add wave -label DRAM_RAS_N             /DRAM_RAS_N
add wave -label DRAM_CAS_N             /DRAM_CAS_N
add wave -label DRAM_WE_N              /DRAM_WE_N
add wave -label DRAM_DQ    -radix hex /DRAM_DQ

# The testbench ends itself via std.env.finish; this bound just caps the run.
run 30us

wave zoomfull
