#!/bin/bash

#Global Functions
ghdl -a ./src/convolution_pack.vhdl

#Component Files
ghdl -a ./src/components/*.vhdl

#Top Level Files
ghdl -a ./src/bo.vhdl
ghdl -a ./src/bc.vhdl
ghdl -a ./src/convolution_module.vhdl


#Testbench Files
ghdl -a ./tests/*.vhdl

echo "Compilation Successful!"

#ghdl -e tb_bo
#ghdl -r tb_bo --vcd=tb_bo.vcd --stop-time=1000ns
