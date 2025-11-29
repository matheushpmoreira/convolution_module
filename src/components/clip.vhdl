library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clip is
	port(
		value         : in  signed(15 downto 0);
		clipped_value : out unsigned(7 downto 0)
	);
end clip;

architecture behavior of clip is
begin
	process(value)
		variable v_int : integer;
	begin
		-- Converte para integer uma única vez para facilitar as comparações
		v_int := to_integer(value);

		if v_int > 255 then
			-- Saturação superior: trava em 255 (FF)
			clipped_value <= (others => '1');
		elsif v_int < 0 then
			-- Saturação inferior: trava em 0 (00)
			clipped_value <= (others => '0');
		else
			-- Faixa passante: converte o integer validado para unsigned de 8 bits
			clipped_value <= to_unsigned(v_int, 8);
		end if;
	end process;
end behavior;
