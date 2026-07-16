# ModelSim/Questa macro for the SDRAM cache testbench.
# Run from peripherals/sdram:  vsim -do testbench_sdram_cache.do

# Project library
vlib work

# Compile. Order matters: package and models before the DUTs and testbench.
# fifo_16 / fifo_512 instantiate the Altera scfifo megafunction; ModelSim Intel
# FPGA Edition ships altera_mf precompiled, so they simulate directly.
vcom sdram_pkg.vhd
vcom ./sim/mti_pkg.vhd ./sim/mt48lc8m16a2.vhd
vcom sdram_controller.vhd
vcom ./fifo_16/fifo_16.vhd
vcom ./fifo_512/fifo_512.vhd
vcom sdram_cache.vhd
vcom testbench_sdram_cache.vhd

# Elaborate
vsim -t ps work.testbench_sdram_cache

# Waveforms
view wave

add wave -height 15 -divider "Cache user side"
add wave -label clk                     /clk_sdram
add wave -label reset                   /rst
add wave -label read_enable             /read_enable
add wave -label read_address -radix hex /read_address
add wave -label read_data    -radix hex /read_data
add wave -label read_lock               /read_lock
add wave -label write_commit            /write_commit
add wave -label write_address -radix hex /write_address
add wave -label write_data   -radix hex /write_data

add wave -height 15 -divider "Cache internals"
add wave -label cache_state                    /cache/cache_state
add wave -label read_fifo_used  -radix unsigned /cache/read_fifo_used
add wave -label read_head       -radix hex     /cache/read_fifo_head_address
add wave -label read_burst_addr -radix hex     /cache/read_burst_address
add wave -label write_fifo_used -radix unsigned /cache/write_fifo_used

add wave -height 15 -divider "Cache <-> controller"
add wave -label sdram_addr       -radix hex /sdram_addr
add wave -label sdram_cs                    /sdram_cs
add wave -label sdram_read                  /sdram_read
add wave -label sdram_write                 /sdram_write
add wave -label sdram_write_data -radix hex /sdram_write_data
add wave -label read_buffer      -radix hex /sdram_read_buffer
add wave -label read_valid_count            /read_valid_count
add wave -label waitrequest                 /waitrequest
add wave -label mem_state /sdram_controller/mem_state

add wave -height 15 -divider "SDRAM bus"
add wave -label DRAM_ADDR -radix hex /DRAM_ADDR
add wave -label DRAM_DQ   -radix hex /DRAM_DQ

# The testbench ends itself via std.env.finish; this bound just caps the run.
run 30us

wave zoomfull
