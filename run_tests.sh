#!/bin/bash

ghdl -e tb_convolution_module
ghdl -r tb_convolution_module --vcd=convolution_module.vcd --stop-time=5000ns
