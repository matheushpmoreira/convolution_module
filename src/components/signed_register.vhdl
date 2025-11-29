library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity signed_register is
    generic(
        G_NBITS     : positive := 8    -- Define o tamanho do registro (número de bits)
    );
    port(
        clock    : in  std_logic;
        reset    : in  std_logic;         -- Assíncrono ativo alto
        enable   : in  std_logic;         -- Habilita a contagem
        data_in  : in  signed(G_NBITS - 1 downto 0);

        data_out : out signed(G_NBITS - 1 downto 0)
    );
end entity signed_register;

architecture rtl of signed_register is
begin

    process(clock, reset)
    begin
        if reset = '1' then
            data_out <= (others => '0');
        elsif rising_edge(clock) then
            if enable = '1' then
                data_out <= data_in;
            end if;
        end if;
    end process;

end architecture rtl;
