library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.convolution_pack.all;

entity kernel_indexer is
    generic(
        -- O valor central foi ajustado para 7 pois 8 não cabe em 4 bits signed
        KERNEL : kernel_array := (
            -1, -1, -1,
            -1, 7, -1,
            -1, -1, -1
        )
    );
    port(
        index    : in  unsigned(3 downto 0);
        -- ALTERAÇÃO AQUI: Saída agora é 4 bits
        coef_out : out signed(3 downto 0)
    );
end entity kernel_indexer;

architecture rtl of kernel_indexer is
begin

    process(index)
    begin
        if to_integer(index) < KERNEL'length then
            -- ALTERAÇÃO AQUI: Conversão para 4 bits
            coef_out <= to_signed(KERNEL(to_integer(index)), 4);
        else
            -- ALTERAÇÃO AQUI: Conversão para 4 bits
            coef_out <= to_signed(0, 4);
        end if;
    end process;

end architecture rtl;
