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
ghdl -a ./src/tests/*.vhdl

echo "Compilation Successful!"

# Elaborate all testbenches automatically
for file in ./src/tests/*.vhdl; do
    entity=$(grep -i "entity" "$file" | head -n 1 | awk '{print $2}')
    echo "Elaborating $entity..."
    ghdl -e "$entity"
done