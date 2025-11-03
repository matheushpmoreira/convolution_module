library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity unsigned_register is
    generic(
        N : positive := 8
    );
    port(
        clk, rst, enable : in  std_logic;
        d                : in  unsigned(N - 1 downto 0);
        q                : out unsigned(N - 1 downto 0)
    );
end unsigned_register;

architecture behavior of unsigned_register is
begin
    process(clk, rst)
    begin
        if rst = '1' then
            q <= (others => '0');
        elsif rising_edge(clk) then
            if enable = '1' then
                q <= d;
            end if;
        end if;
    end process;
end architecture behavior;