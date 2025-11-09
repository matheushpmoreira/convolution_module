ghdl -a ./src/convolution_pack.vhdl
ghdl -a ./src/generic_counter.vhdl
ghdl -a ./src/offset_indexer.vhdl
ghdl -a ./src/address_calculator.vhdl
ghdl -a ./src/kernel_indexer.vhdl
ghdl -a ./src/multi.vhdl
ghdl -a ./src/bo.vhdl

ghdl -a ./tb/tb_bo.vhdl

ghdl -e tb_bo

ghdl -r tb_bo --vcd=tb_bo.vcd --stop-time=1000ns

