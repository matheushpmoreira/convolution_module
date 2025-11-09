library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.convolution_pack.all;          -- para o tipo kernel_array, se já existir aqui

entity kernel_indexer is
    generic(
        KERNEL : kernel_array := (
            -1, -1, -1,
            -1, 8, -1,
            -1, -1, -1
        )
    );
    port(
        index    : in  unsigned(3 downto 0); -- índice de 0 a 8
        coef_out : out signed(7 downto 0)
    );
end entity kernel_indexer;

architecture rtl of kernel_indexer is
begin

    process(index)
    begin
        if to_integer(index) < KERNEL'length then
            coef_out <= to_signed(KERNEL(to_integer(index)), 8);
        else
            coef_out <= to_signed(0, 8);
        end if;
    end process;

end architecture rtl;
