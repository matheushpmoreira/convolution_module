library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity unsigned_register is
    generic(
        G_NBITS     : positive := 8
    );
    port(
        clock    : in  std_logic;
        reset    : in  std_logic;
        enable   : in  std_logic;
        data_in  : in  unsigned(G_NBITS - 1 downto 0);

        data_out : out unsigned(G_NBITS - 1 downto 0)
    );
end entity unsigned_register;

architecture rtl of unsigned_register is
begin

    process(clock, reset)
    begin
        if reset = '1' then
            data_out <= resize("0", data_out'length);
        elsif rising_edge(clock) then
            if enable = '1' then
                data_out <= data_in;
            end if;
        end if;
    end process;

end architecture rtl;
