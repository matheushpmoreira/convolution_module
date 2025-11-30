library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clip is
	generic(
		LOW  : integer  := 0;
		HIGH : integer  := 255
	);
	port(
		value         : in  signed(15 downto 0);
		clipped_value : out unsigned(7 downto 0)
	);
end clip;

architecture behavior of clip is
begin
	clip_value : process(value)
	begin
		if to_integer(value) > HIGH then
			clipped_value <= to_unsigned(HIGH, clipped_value'length);
		elsif (to_integer(value) < LOW) then
			clipped_value <= to_unsigned(LOW, clipped_value'length);
		else
			clipped_value <= unsigned(resize(value, clipped_value'length));
		end if;
	end process clip_value;
end behavior;
