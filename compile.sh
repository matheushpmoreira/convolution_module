#!/bin/bash

# Limpa compilações anteriores para evitar conflitos de versão
rm -f *.cf

# Flags Comuns:
# --std=08   : Habilita VHDL-2008 (Necessário para usar text_line'length e leitura moderna)
# -fsynopsys : Permite usar o pacote não-padrão ieee.std_logic_textio
FLAGS="--std=08 -fsynopsys"

echo "Compiling Pack..."
ghdl -a $FLAGS ./src/convolution_pack.vhdl

echo "Compiling Components..."
ghdl -a $FLAGS ./src/components/*.vhdl

echo "Compiling Top Level..."
ghdl -a $FLAGS ./src/bo.vhdl
ghdl -a $FLAGS ./src/bc.vhdl
ghdl -a $FLAGS ./src/convolution_module.vhdl

echo "Compiling Testbenches..."
# O testbench PRECISA das flags aqui na análise também
ghdl -a $FLAGS ./src/tests/*.vhdl

echo "Compilation Analysis Successful!"

# Elaborate all testbenches automatically
for file in ./src/tests/*.vhdl; do
    # Extrai o nome da entidade (case insensitive)
    entity=$(grep -i "entity" "$file" | head -n 1 | awk '{print $2}')
    
    if [ ! -z "$entity" ]; then
        echo "Elaborating $entity..."
        # As flags devem vir ANTES do nome da entidade no comando de elaboração (-e)
        ghdl -e $FLAGS "$entity"
    fi
done