library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.convolution_pack.all;

entity tb_kernel_indexer is
end entity;

architecture tb of tb_kernel_indexer is

    -- Sinais de entrada e saída
    signal index    : unsigned(3 downto 0) := (others => '0');
    signal coef_out : signed(7 downto 0);

    -- Constante do kernel (filtro de borda)
    constant TEST_KERNEL : kernel_array := (
        -1, -1, -1,
        -1, 8, -1,
        -1, -1, -1
    );

begin

    -- DUT (Device Under Test)
    DUT : entity work.kernel_indexer
        generic map(
            KERNEL => TEST_KERNEL
        )
        port map(
            index    => index,
            coef_out => coef_out
        );

    -- Processo de teste
    stim_proc : process
        variable L : line;
    begin
        for i in 0 to 8 loop
            index <= to_unsigned(i, 4);
            wait for 10 ns;
            write(L, string'("Index "));
            write(L, i);
            write(L, string'(": Coef = "));
            write(L, integer(to_integer(coef_out)));
            writeline(output, L);
        end loop;

        -- Testar fora do range (segurança)
        index <= to_unsigned(9, 4);
        wait for 10 ns;
        write(L, string'("Index 9 (fora do range): Coef = "));
        write(L, integer(to_integer(coef_out)));
        writeline(output, L);

        wait;
    end process;

end architecture;
