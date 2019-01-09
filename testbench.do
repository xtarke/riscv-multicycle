#******************************************************************************
#                                                                             *
#                  Copyright (C) 2016 IFSC                                    *
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
vcom ./memory/imemory.vhd
vcom ./decoder/iregister.vhd

vsim -t ns work.detectprior_tb

view wave
add wave -radix binary /p0
add wave -radix binary /p1
add wave -radix binary /p2
add wave -radix binary /p3

add wave -radix binary /x0
add wave -radix binary /x1

add wave -radix binary /dec_1/x

add wave -radix binary /int

run 50 ns
