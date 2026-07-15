vlib rtl_work
vmap work rtl_work

vlib altera_mf
vmap altera_mf altera_mf

vcom -2008 -work altera_mf "C:/altera_lite/25.1std/quartus/eda/sim_lib/altera_mf_components.vhd"
vcom -2008 -work altera_mf "C:/altera_lite/25.1std/quartus/eda/sim_lib/altera_mf.vhd"

vcom -2008 ../../memory/iram_quartus.vhd
vcom -2008 ../../memory/dmemory.vhd
vcom -2008 ../../memory/instructionbusmux.vhd
vcom -2008 ../../memory/databusmux.vhd
vcom -2008 ../../memory/iodatabusmux.vhd

vcom -2008 ../../alu/alu_types.vhd
vcom -2008 ../../alu/alu.vhd
vcom -2008 ../../alu/m/division_functions.vhd
vcom -2008 ../../alu/m/quick_naive.vhd
vcom -2008 ../../alu/m/M_types.vhd
vcom -2008 ../../alu/m/M.vhd

vcom -2008 ../../decoder/decoder_types.vhd
vcom -2008 ../../decoder/iregister.vhd
vcom -2008 ../../decoder/decoder.vhd
vcom -2008 ../../registers/register_file.vhd

vcom -2008 ../../core/csr.vhd
vcom -2008 ../../core/core.vhd
vcom -2008 ../../core/txt_util.vhdl
vcom -2008 ../../core/trace_debug.vhd

vcom -2008 ../../peripherals/gpio/gpio.vhd
vcom -2008 ../../peripherals/gpio/led_displays.vhd

vcom -2008 rtc2.vhd
vcom -2008 testbench2.vhd


vsim -voptargs=+acc -t ns work.coretestbench

view wave

add wave -divider {Clock and Reset}
add wave -radix binary /clk
add wave -radix binary /rst

add wave -divider {Instruction}
add wave -radix hex /iaddress
add wave -radix hex /idata
add wave -radix ascii /debugString

add wave -divider {Core}
add wave -radix hex /myRiscv/pc
add wave -radix hex /myRiscv/alu_out
add wave /myRiscv/decoder0/state

add wave -divider {Data Bus}
add wave -radix hex /daddress
add wave -radix hex /ddata_w
add wave -radix hex /ddata_r
add wave -radix hex /ddata_r_periph
add wave -radix hex /ddata_r_rtc
add wave -radix binary /d_we
add wave -radix binary /d_rd
add wave -radix binary /dcsel

add wave -divider {RTC}
add wave -radix unsigned /rtc_sec
add wave -radix unsigned /rtc_min
add wave -radix unsigned /rtc_hour
add wave -radix unsigned /rtc_inst/sec_reg
add wave -radix unsigned /rtc_inst/min_reg
add wave -radix unsigned /rtc_inst/hour_reg
add wave -radix hex /rtc_inst/ctrl_reg
add wave -radix unsigned /rtc_inst/tick_counter

add wave -divider {GPIO e Displays}
add wave -radix hex /gpio_output
add wave -radix hex /LEDR
add wave -radix hex /HEX0
add wave -radix hex /HEX1
add wave -radix hex /HEX2
add wave -radix hex /HEX3
add wave -radix hex /HEX4
add wave -radix hex /HEX5

run 20 ms
wave zoomfull