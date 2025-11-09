library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package convolution_pack is

    type tipo_bcbo is record            -- juntando os bits usados para o BC e BO
        R_CW, R_CH, R_CI : std_logic;   -- Reset contadores
        E_CW, E_CH, E_CI : std_logic;   -- Enable contadores
        E_ACC            : std_logic;   -- Enable acumulador
        R_ACC            : std_logic;   -- Reset acumulador
    end record;

    -- Tipo que representa um kernel 3x3 de convolução com coeficientes inteiros de -128 a 127.
    type kernel_array is array (0 to 8) of integer range -128 to 127;

    -- Exemplo de constante de kernel (filtro de borda)
    constant kernel_edge_detection : kernel_array := (-1, -1, -1,
                                                      -1, 8, -1,
                                                      -1, -1, -1);

    -- Exemplo de constante de kernel (filtro de borda)
    constant kernel_testing : kernel_array := (-1, -2, -3,
                                               4, 5, 6,
                                               -7, 8, -9);

    -- Calcula o número de bits necessários para indexar todas as amostras
    function address_length(img_width : positive; img_height : positive) return positive;

    -- Função para calcular o número de bits necessários 
    -- para armazenar 'n' valores (ex: 0 até n-1)
    function log2_ceil(n : positive) return natural;

end package convolution_pack;

package body convolution_pack is

    -- Função que determina a largura do endereço (em bits) necessário para indexar os
    -- vetores parciais de P amostras. Calcula log2(samples_per_block / parallel_samples), com arredondamento.
    function address_length(img_width : positive; img_height : positive)
    return positive is
    begin
        return integer(ceil(log2(real(img_width) * real(img_height))));
    end function address_length;

    function log2_ceil(n : positive)
    return natural is
    begin
        return integer(ceil(log2(real(n))));
    end function log2_ceil;

end package body convolution_pack;
