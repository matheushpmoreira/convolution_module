library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.convolution_pack.all;

entity address_calculator is
    generic(
        img_width  : positive;
        img_height : positive
    );
    port(
        in_x     : in  unsigned(log2_ceil(img_width) - 1 downto 0);
        in_y     : in  unsigned(log2_ceil(img_height) - 1 downto 0);
        out_addr : out unsigned(address_length(img_width, img_height) - 1 downto 0)
    );
end entity address_calculator;

architecture rtl of address_calculator is
    
    -- Constante para o tamanho final do endereço
    constant C_ADDR_LEN : natural := out_addr'length;

    signal a : unsigned(C_ADDR_LEN - 1 downto 0);
    signal b : unsigned(C_ADDR_LEN - 1 downto 0);

begin

    a <= resize(in_y, C_ADDR_LEN);      -- in_x
    b <= to_unsigned(img_width, C_ADDR_LEN); -- in_y

    out_addr <= resize(a * b, C_ADDR_LEN) + in_x;

end architecture rtl;
