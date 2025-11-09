library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.convolution_pack.all;

entity convolution_module is
	generic(
		-- obrigatório ---
		img_width   : positive := 256; -- número de valores numa linha de imagem
		img_height   : positive := 256 -- número de linhas de valores na imagem
	);
	
	port(
		clk        : in  std_logic;     -- ck
		rst        : in  std_logic;     -- reset
		enable     : in  std_logic;     -- iniciar operação
		done       : out std_logic      -- pronto
	);

end entity convolution_module;

architecture arch of convolution_module is
begin
	


end architecture arch; 