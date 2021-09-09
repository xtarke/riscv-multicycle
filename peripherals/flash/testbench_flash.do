vlib work

if ![info exists QUARTUS_INSTALL_DIR] { 
  set QUARTUS_INSTALL_DIR "~/intelFPGA_lite/20.1/quartus/"
}

# entities/libs required for altera onchip flash below
#vlog /home/rgnagel/intelFPGA_lite/20.1/quartus/eda/fv_lib/verilog/dffep.v
#vlog /home/rgnagel/intelFPGA_lite/20.1/quartus/eda/fv_lib/verilog/lpm_shiftreg.v
#vcom /home/rgnagel/intelFPGA_lite/20.1/modelsim_ase/altera/vhdl/src/altera_mf/altera_mf_components.vhd
#vcom /home/rgnagel/intelFPGA_lite/20.1/modelsim_ase/altera/vhdl/src/altera_mf/altera_mf.vhd
#vlog /home/rgnagel/intelFPGA_lite/20.1/modelsim_ase/altera/verilog/src/fiftyfivenm_atoms.v
#vlog /home/rgnagel/intelFPGA_lite/20.1/modelsim_ase/altera/verilog/src/fiftyfivenm_atoms_ncrypt.v

vlog "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_primitives.v"               -work altera_ver      
vlog "$QUARTUS_INSTALL_DIR/eda/sim_lib/220model.v"                        -work lpm_ver         
vlog "$QUARTUS_INSTALL_DIR/eda/sim_lib/sgate.v"                           -work sgate_ver       
vlog "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_mf.v"                       -work altera_mf_ver   
vlog "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_lnsim.sv"                   -work altera_lnsim_ver
vlog "$QUARTUS_INSTALL_DIR/eda/sim_lib/fiftyfivenm_atoms.v"               -work fiftyfivenm_ver 
vlog "$QUARTUS_INSTALL_DIR/eda/sim_lib/mentor/fiftyfivenm_atoms_ncrypt.v" -work fiftyfivenm_ver 
vcom "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_syn_attributes.vhd"         -work altera          
vcom "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_standard_functions.vhd"     -work altera          
vcom "$QUARTUS_INSTALL_DIR/eda/sim_lib/alt_dspbuilder_package.vhd"        -work altera          
vcom "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_europa_support_lib.vhd"     -work altera          
vcom "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_primitives_components.vhd"  -work altera          
vcom "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_primitives.vhd"             -work altera          
vcom "$QUARTUS_INSTALL_DIR/eda/sim_lib/220pack.vhd"                       -work lpm             
vcom "$QUARTUS_INSTALL_DIR/eda/sim_lib/220model.vhd"                      -work lpm             
vcom "$QUARTUS_INSTALL_DIR/eda/sim_lib/sgate_pack.vhd"                    -work sgate           
vcom "$QUARTUS_INSTALL_DIR/eda/sim_lib/sgate.vhd"                         -work sgate           
vcom "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_mf_components.vhd"          -work altera_mf       
vcom "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_mf.vhd"                     -work altera_mf       
vlog "$QUARTUS_INSTALL_DIR/eda/sim_lib/mentor/altera_lnsim_for_vhdl.sv"   -work altera_lnsim 
vcom "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_lnsim_components.vhd"       -work altera_lnsim    
vlog "$QUARTUS_INSTALL_DIR/eda/sim_lib/mentor/fiftyfivenm_atoms_ncrypt.v" -work fiftyfivenm     
vcom "$QUARTUS_INSTALL_DIR/eda/sim_lib/fiftyfivenm_atoms.vhd"             -work fiftyfivenm     
vcom "$QUARTUS_INSTALL_DIR/eda/sim_lib/fiftyfivenm_components.vhd"        -work fiftyfivenm     

set FLASH_SIMULATION_DIR "./sint_only_flash/de10_lite/flash/simulation"

vlog $FLASH_SIMULATION_DIR/submodules/altera_onchip_flash_util.v
vlog $FLASH_SIMULATION_DIR/submodules/altera_onchip_flash_avmm_data_controller.v
vlog $FLASH_SIMULATION_DIR/submodules/altera_onchip_flash_avmm_csr_controller.v
vlog $FLASH_SIMULATION_DIR/submodules/altera_onchip_flash.v

vcom $FLASH_SIMULATION_DIR/flash.vhd
vcom flash_bus.vhd 
vcom testbench_flash.vhd

#Simula (work é o diretorio, testbench é o nome da entity)
vsim -t us work.testbench

view wave

# -radix: binary, hex, dec
# -label: nome da forma de onda

add wave -label clk /clk
add wave -label rst /rst
add wave -radix hex -label daddress /daddress

add wave -label ddata_w /ddata_w
add wave -label ddata_r /ddata_r
add wave /d_we
add wave /d_rd
add wave -label FSM /dut/state

add wave -height 15 -divider "avalon-mm bus"
add wave -label data_addr /dut/avmm_data_addr
add wave -label data_read /dut/avmm_data_read
add wave -label data_writedata /dut/avmm_data_writedata
add wave -label data_write /dut/avmm_data_write
add wave -label data_readdata /dut/avmm_data_readdata
add wave -label data_waitrequest /dut/avmm_data_waitrequest
add wave -label data_readdatavalid /dut/avmm_data_readdatavalid
add wave -label data_burstcount /dut/avmm_data_burstcount
add wave -label csr_addr /dut/avmm_csr_addr
add wave -label csr_read /dut/avmm_csr_read
add wave -label csr_writedata /dut/avmm_csr_writedata
add wave -label csr_write /dut/avmm_csr_write
add wave -radix hex -label csr_readdata /dut/avmm_csr_readdata

run 500ms

wave zoomfull
write wave wave.ps