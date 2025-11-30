library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.convolution_pack.all;

entity kernel_indexer is
    generic(
        KERNEL : kernel_array
    );
    port(
        index    : in  unsigned(3 downto 0);
        coef_out : out signed(3 downto 0)
    );
end entity kernel_indexer;

architecture rtl of kernel_indexer is
begin

    process(index)
    begin
        if to_integer(index) < KERNEL'length then
            coef_out <= to_signed(KERNEL(to_integer(index)), 4);
        else
            coef_out <= to_signed(0, 4);
        end if;
    end process;

end architecture rtl;
