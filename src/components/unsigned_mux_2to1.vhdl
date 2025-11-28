library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity unsigned_mux_2to1 is
	generic(
		N : positive := 8 -- número de bits das entradas e da saída
	);
	port(
		sel        : in  std_logic;                        -- sinal de seleção
		in_0, in_1 : in  unsigned(N - 1 downto 0); -- entradas do mux
		y          : out unsigned(N - 1 downto 0)  -- saída do mux
	);
end unsigned_mux_2to1;

architecture behavior of unsigned_mux_2to1 is
begin
    y <= in_0 when sel = '0' else in_1;
end architecture behavior;