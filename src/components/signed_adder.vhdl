library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity signed_adder is
	generic(
		N : positive := 8
	);
	port(
		input_a : in  signed(N - 1 downto 0);
		input_b : in  signed(N - 1 downto 0);
		sum     : out signed(N - 1 downto 0)
	);
end signed_adder;

architecture arch of signed_adder is
begin
    sum <= resize(input_a, N) + resize(input_b, N);
end architecture arch;