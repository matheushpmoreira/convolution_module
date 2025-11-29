library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package convolution_pack is

    type tipo_comandos is record
        -- Contador Janela
        E_CW, R_CW     : std_logic;
        -- Contador Linha
        E_CH, R_CH     : std_logic;
        -- Contador Coluna
        E_CI, R_CI     : std_logic;
        -- Acumulador (acc_reg)
        E_ACC, R_ACC   : std_logic;
        -- Registrador Addr (addr_reg)
        E_ADDR, R_ADDR : std_logic;
        -- Registrador Sample_in (mem_reg)
        E_MEM, R_MEM   : std_logic;
    end record;

    type tipo_status is record
        done_window : std_logic;
        done_width  : std_logic;
        done_height : std_logic;
        invalid     : std_logic;
    end record;

    -- Tipo que representa um kernel 3x3 de convolução com coeficientes inteiros de -128 a 127.
    type kernel_array is array (0 to 8) of integer range -8 to 7;

    -- Exemplo de kernel: Filtro de detecção de bordas
    constant kernel_edge_detection : kernel_array := (
        1, 2, 3,
        4, 5, 6,                 
       -4,-5 , 7
    );

    constant identity_kernel : kernel_array := (
        0, 0, 0,
        0, 1, 0,
        0, 0, 0
    );
    

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
