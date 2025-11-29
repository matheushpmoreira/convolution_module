library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplier is
    port(
        a_signed   : in  signed(3 downto 0);
        b_unsigned : in  unsigned(7 downto 0);
        result_out : out signed(15 downto 0)  -- resultado completo sem overflow
    );
end entity multiplier;


architecture rtl of multiplier is
begin
    process(a_signed, b_unsigned)
        variable int_a    : integer;
        variable int_b    : integer;
        variable int_prod : integer;
    begin
        -- converte operandos para integer (mantendo sinal corretamente)
        int_a := to_integer(a_signed);  -- pode ser negativo
        int_b := to_integer(b_unsigned); -- >= 0

        -- multiplica como integer (sem truncamento inesperado)
        int_prod := int_a * int_b;

        -- converte o resultado para signed(15 downto 0)
        -- se int_prod estiver fora do intervalo -32768..32767, haverá truncamento ao converter;
        -- se preferir saturação, veja abaixo.
        result_out <= to_signed(int_prod, 16);
    end process;
end architecture rtl;

