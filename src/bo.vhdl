library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.convolution_pack.all;

entity bo is
    generic(
        -- obrigatório ---
        img_width       : positive := 256; -- número de valores numa linha de imagem
        img_height      : positive := 256; -- número de linhas de valores na imagem
        KERNEL          : kernel_array
    );

    port(

        clk            : in  std_logic; -- clock

        addr : out unsigned(address_length(img_width, img_height) - 1 downto 0);
       

        sample_in    : in  unsigned(7 downto 0);
        sample_out   : out unsigned(7 downto 0);

        -- Sinais de controle e status
        comandos      : in  tipo_comandos;
        status        : out tipo_status
    );
end entity bo;

architecture arch of bo is


    signal count_w : unsigned(log2_ceil(img_width) - 1 downto 0);
    signal count_h : unsigned(log2_ceil(img_height) - 1 downto 0);
    signal count_i : unsigned(3 downto 0);

    signal offset_x : unsigned(log2_ceil(img_width) - 1 downto 0);
    signal offset_y : unsigned(log2_ceil(img_height) - 1 downto 0);

    signal addr_calc_out : unsigned(address_length(img_width, img_height) - 1 downto 0);

    signal coef_out : signed(3 downto 0);


    signal sample_reg_out : unsigned(7 downto 0);

    signal mul_out : signed(15 downto 0);

    signal acc_out : signed(15 downto 0);
    

begin
    

    Counter_Width: entity work.generic_counter
        generic map(
            G_NBITS     => log2_ceil(img_width),
            G_MAX_COUNT => img_width - 1
        )
        port map(
            clock  => clk,
            reset  => comandos.R_CW,
            enable => comandos.E_CW,
            count  => count_w,
            done   => status.done_width
        );
    
    Counter_Height: entity work.generic_counter
        generic map(
            G_NBITS     => log2_ceil(img_height),
            G_MAX_COUNT => img_height - 1
        )
        port map(
            clock  => clk,
            reset  => comandos.R_CH,
            enable => comandos.E_CH,
            count  => count_h,
            done   => status.done_height
        );

    Counter_Index: entity work.generic_counter
        generic map(
            G_NBITS     => 4,
            G_MAX_COUNT => 9
        )
        port map(
            clock  => clk,
            reset  => comandos.R_CI,
            enable => comandos.E_CI,
            count  => count_i,
            done   => status.done_window
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
            invalid => status.invalid
        );
    

    Add_Calc: entity work.address_calculator
        generic map(
            img_width  => img_width,
            img_height => img_height
        )
        port map(
            in_x     => offset_x,
            in_y     => offset_y,
            out_addr => addr_calc_out
        );

    Addr_Reg: entity work.unsigned_register
        generic map(
            G_NBITS => address_length(img_width, img_height)
        )
        port map(
            clock    => clk,
            reset    => comandos.R_ADDR,
            enable   => comandos.E_ADDR,
            data_in  => addr_calc_out,
            data_out => addr
        );
    
    Sample_in_Reg: entity work.unsigned_register
        generic map(
            G_NBITS => 8
        )
        port map(
            clock    => clk,
            reset    => comandos.R_MEM,
            enable   => comandos.E_MEM,
            data_in  => sample_in,
            data_out => sample_reg_out  
        );
    

    kernel_indexer_inst : entity work.kernel_indexer
        generic map(
            KERNEL => KERNEL
        )
        port map(
            index    => count_i,
            coef_out => coef_out
        );
    
    multiplier_inst : entity work.multiplier
        port map(
            a_signed   => coef_out,
            b_unsigned => sample_reg_out,
            result_out => mul_out
        );

    accumulator_inst : entity work.accumulator
        port map(
            clk      => clk,
            rst      => comandos.R_ACC,
            enable   => comandos.E_ACC,
            data_in  => mul_out,
            data_out => acc_out
        );
    
    clip_inst : entity work.clip
        port map(
            value         => acc_out,
            clipped_value => sample_out
        );
    
    


end architecture;