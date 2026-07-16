# ModelSim/Questa macro for the full core + SDRAM (cache) testbench.
# Run headless from peripherals/sdram:  vsim -c -do coretestbench.do
#
# iram_quartus instantiates the Altera altsyncram megafunction. ModelSim Intel
# FPGA Edition already ships a precompiled altera_mf library (mapped in the
# install's modelsim.ini), so it does not need to be compiled here.

vlib work

# Design sources, dependency order (packages first). fifo_sim provides the
# behavioral fifo_16 / fifo_512 the cache uses (real ones are megafunctions).
vcom -2008 ../../alu/alu_types.vhd
vcom -2008 ../../alu/m/M_types.vhd
vcom -2008 ../../alu/m/division_functions.vhd
vcom -2008 ../../decoder/decoder_types.vhd
vcom -2008 ./sdram_pkg.vhd
vcom -2008 ../../core/txt_util.vhdl

vcom -2008 ../../alu/alu.vhd
vcom -2008 ../../alu/m/quick_naive.vhd
vcom -2008 ../../alu/m/M.vhd
vcom -2008 ../../decoder/iregister.vhd
vcom -2008 ../../decoder/decoder.vhd
vcom -2008 ../../registers/register_file.vhd
vcom -2008 ../../core/csr.vhd
vcom -2008 ../../memory/iram_quartus.vhd
vcom -2008 ../../memory/dmemory.vhd
vcom -2008 ../../memory/instructionbusmux.vhd
vcom -2008 ../../memory/databusmux.vhd
vcom -2008 ../../memory/iodatabusmux.vhd
vcom -2008 ../../core/core.vhd
vcom -2008 ../../core/trace_debug.vhd
vcom -2008 ../../peripherals/gpio/gpio.vhd

vcom -2008 ./sim/mti_pkg.vhd ./sim/mt48lc8m16a2.vhd
vcom -2008 ./sdram_controller.vhd
vcom -2008 ./sim/fifo_sim.vhd
vcom -2008 ./sdram_cache.vhd
vcom -2008 ./core_sdram_testbench.vhd

vsim -t ns work.core_sdram_testbench

view wave
add wave -radix binary /clk
add wave -radix binary /rst

add wave -height 15 -divider "Instruction Memory"
add wave -label iAddr -radix hex /address
add wave -label iWord -radix hex /idata
add wave -label decoded -radix ASCII /debugString

add wave -height 15 -divider "Data bus"
add wave -label daddress -radix hex /daddress
add wave -label ddata_r  -radix hex /ddata_r
add wave -label ddata_w  -radix hex /ddata_w
add wave -label dmask    -radix bin /dmask
add wave -label dcsel               /dcsel
add wave -label d_we                /d_we
add wave -label d_rd                /d_rd

add wave -height 15 -divider "CPU -> cache write bridge"
add wave -label cpu_wr                        /cpu_wr
add wave -label wr_high                       /wr_high
add wave -label cache_write_commit            /cache_write_commit
add wave -label cache_write_address -radix hex /cache_write_address
add wave -label cache_write_data    -radix hex /cache_write_data

add wave -height 15 -divider "Cache internals"
add wave -label cache_state                    /cache/cache_state
add wave -label read_fifo_used  -radix unsigned /cache/read_fifo_used
add wave -label write_fifo_used -radix unsigned /cache/write_fifo_used

add wave -height 15 -divider "SDRAM"
add wave -label mem_state              /sdram_controller/mem_state
add wave -label DRAM_ADDR  -radix hex  /DRAM_ADDR
add wave -label DRAM_DQ    -radix hex  /DRAM_DQ
add wave -label DRAM_CS_N               /DRAM_CS_N
add wave -label DRAM_RAS_N              /DRAM_RAS_N
add wave -label DRAM_CAS_N              /DRAM_CAS_N
add wave -label DRAM_WE_N               /DRAM_WE_N

run 600000 ns
wave zoomfull
