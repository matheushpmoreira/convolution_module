library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package convolution_definitions is


    --type datapath_configuration_t is record

    --end record;



    -- Tipo que representa um kernel 3x3 de convolução com coeficientes inteiros de -128 a 127.
    type kernel_array is array (0 to 8) of integer range -128 to 127;

    -- Exemplo de constante de kernel (filtro de borda)
    constant kernel_edge_detection : kernel_array := ( -1, -1, -1,
                                                     -1,  8, -1,
                                                     -1, -1, -1);


    -- Calcula o número de bits necessários para indexar todasas amostras
    function address_length(img_width : positive; img_height : positive) return positive;

end package convolution_definitions;

package body convolution_definitions is

    -- Função que determina a largura do endereço (em bits) necessário para indexar os
    -- vetores parciais de P amostras. Calcula log2(samples_per_block / parallel_samples), com arredondamento.
    function address_length(img_width : positive; img_height : positive)
    return positive is
    begin
        return integer(ceil(log2(real(img_width) * real(img_height))));
    end function address_length;

end package body convolution_definitions;