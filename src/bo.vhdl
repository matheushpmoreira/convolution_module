library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.convolution_pack.all;

entity bo is
    generic(
        -- obrigatório ---
        img_width       : positive := 256; -- número de valores numa linha de imagem
        img_height      : positive := 256 -- número de linhas de valores na imagem
    );

    port(
        clk            : in  std_logic; -- clock
        R_CW, R_CH, R_CI : in  std_logic; -- reset contadores
        E_CW, E_CH, E_CI : in  std_logic; -- iniciar contadores

        sample_address : out unsigned(address_length(img_width, img_height) - 1 downto 0);

        sample_in    : in  unsigned(7 downto 0);
        sample_out   : out unsigned(7 downto 0);

        done_width, done_height, done_window : out std_logic
    );
end entity bo;

architecture arch of bo is


    signal count_w : unsigned(log2_ceil(img_width) - 1 downto 0);
    signal count_h : unsigned(log2_ceil(img_height) - 1 downto 0);
    signal count_i : unsigned(3 downto 0);

    signal offset_x : unsigned(log2_ceil(img_width) - 1 downto 0);
    signal offset_y : unsigned(log2_ceil(img_height) - 1 downto 0);


    signal coef_out : signed(7 downto 0);


    signal sample_mult : signed(15 downto 0);

    signal invalid : std_logic;
begin
    

    Counter_Width: entity work.generic_counter
        generic map(
            G_NBITS     => log2_ceil(img_width),
            G_MAX_COUNT => img_width
        )
        port map(
            clock  => clk,
            reset  => R_CW,
            enable => E_CW,
            count  => count_w,
            done   => done_width
        );
    
    Counter_Height: entity work.generic_counter
        generic map(
            G_NBITS     => log2_ceil(img_height),
            G_MAX_COUNT => img_height
        )
        port map(
            clock  => clk,
            reset  => R_CH,
            enable => E_CH,
            count  => count_h,
            done   => done_height
        );

    Counter_Index: entity work.generic_counter
        generic map(
            G_NBITS     => 4,
            G_MAX_COUNT => 8
        )
        port map(
            clock  => clk,
            reset  => R_CI,
            enable => E_CI,
            count  => count_i,
            done   => done_window
        );
    
    Offset_Indexer: entity work.offset_indexer
        generic map(
            img_width  => img_width,
            img_height => img_height
        )
        port map(
            in_x    => count_w,
            in_y    => count_h,
            out_x   => offset_x,
            out_y   => offset_y,
            index   => count_i,
            invalid => invalid
        );
    

    Add_Calc: entity work.address_calculator
        generic map(
            img_width  => img_width,
            img_height => img_height
        )
        port map(
            in_x     => offset_x,
            in_y     => offset_y,
            out_addr => sample_address
        );
    
    Kernel_indexer_comp : entity work.kernel_indexer
        generic map(
            KERNEL => kernel_edge_detection
        )
        port map(
            index    => count_i,
            coef_out => coef_out
        );
        

    Multiplier: entity work.multiplier
        port map(
            a_signed   => coef_out,
            b_unsigned => sample_in,
            result_out => sample_mult
        );

    
end architecture;
