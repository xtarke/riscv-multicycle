
# init !
vlib work

	# dependencias
	vcom spi_slave.vhd spi_master.vhd accelerometer_adxl345.vhd testbench_core_no.vhd

	# entity of testbench.vhd
	vsim -t ns work.e_testbench

	view wave

	# ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
	add wave -radix binary -label  clk 	/clk
	add wave -radix binary -label  rst  /rst

	# ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
	add wave -height 20 -divider "accelerometer"
	add wave -radix unsigned -label state 	/e_accelerometer/state
	add wave -radix hex  -label  buf_Tx     /e_accelerometer/spi_tx_data
	add wave -radix hex  -label  buf_Rx     /e_accelerometer/spi_rx_data
	add wave -radix hex  -label  axe_x      /e_accelerometer/axi_x_int
	add wave -radix hex  -label  axe_y      /e_accelerometer/axi_y_int
	add wave -radix hex  -label  axe_z      /e_accelerometer/axi_z_int
	
	# ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
	add wave -height 20 -divider "SPI"
	add wave -radix binary   -label ss_n          /ss_n
	add wave -radix binary   -label miso          /miso
	add wave -radix binary   -label mosi          /mosi
	add wave -radix binary   -label sclk          /sclk

	# ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
	add wave -height 20 -divider "adxl345_slave"
	add wave -radix binary   -label tx_start      /e_spi_slave/rd_add
	add wave -radix binary   -label tx_axe        /machine_slave	
	add wave -radix hex      -label tx_data       /tx_load_data
	add wave -radix hex      -label tx_shifter    /e_spi_slave/tx_buf


# run !
run 5 us

wave zoomfull

