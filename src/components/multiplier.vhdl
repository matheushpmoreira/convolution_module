library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplier is
    port(
        a_signed   : in  signed(3 downto 0); -- 4-bit signed  (-8 .. +7)
        b_unsigned : in  unsigned(7 downto 0); -- 8-bit unsigned (0 .. 255)
        result_out : out signed(15 downto 0) -- 16-bit full product
    );
end entity multiplier;

architecture rtl of multiplier is
    -- sinais intermediários sem alterar a semântica
    signal a_ext : signed(15 downto 0);
    signal b_ext : signed(15 downto 0);
begin

    -- sign-extend a_signed para 16 bits
    a_ext <= resize(a_signed, 16);

    b_ext <= signed(resize(b_unsigned, 16));

    -- multiplicação correta (sem integer / sem variável)
    result_out <= resize(a_ext * b_ext, 16);

end architecture rtl;
