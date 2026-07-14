vlib work

vcom -2008 rtc2.vhd
vcom -2008 tb_rtc2.vhd

vsim -voptargs=+acc work.tb_rtc2

view wave
view structure
view signals

add wave -divider {Clock}
add wave sim:/tb_rtc2/clk
add wave sim:/tb_rtc2/rst

add wave -divider {Barramento}
add wave -radix hex sim:/tb_rtc2/daddress
add wave -radix hex sim:/tb_rtc2/ddata_w
add wave -radix hex sim:/tb_rtc2/ddata_r
add wave sim:/tb_rtc2/d_we
add wave sim:/tb_rtc2/d_rd
add wave sim:/tb_rtc2/dcsel



add wave -divider {Registradores}
add wave -radix unsigned sim:/tb_rtc2/DUT/sec_reg
add wave -radix unsigned sim:/tb_rtc2/DUT/min_reg
add wave -radix unsigned sim:/tb_rtc2/DUT/hour_reg
add wave -radix unsigned sim:/tb_rtc2/DUT/day_reg
add wave -radix unsigned sim:/tb_rtc2/DUT/month_reg
add wave -radix unsigned sim:/tb_rtc2/DUT/year_reg
add wave -radix hex sim:/tb_rtc2/DUT/ctrl_reg
add wave -radix unsigned sim:/tb_rtc2/DUT/tick_counter

run 1 us

wave zoomfull