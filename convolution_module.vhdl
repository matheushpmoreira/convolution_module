library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.convolution_definitions.all;

entity convolution_module is
	generic(
		-- obrigatório ---
		img_width   : positive := 256; -- número de valores numa linha de imagem
		img_height   : positive := 256; -- número de linhas de valores na imagem
		
		bits_per_sample : positive := 8 -- número de bits por amostra
	);
	port(
		clk        : in  std_logic;     -- ck
		rst        : in  std_logic;     -- reset
		enable     : in  std_logic;     -- iniciar
	
		
		read_mem   : out std_logic;     -- read
		--write_mem  : out std_logic; 	  -- write

		sample_address    : out std_logic_vector (address_length(img_width, img_height) - 1 downto 0); -- endereço de ROM onde esta a amostra a ser lida 

		sample_in     : in  std_logic_vector(bits_per_sample - 1 downto 0);	-- amostra a ser lida da ROM

		sample_out : out std_logic_vector (bits_per_sample - 1 downto 0); -- saída de sample lida da memória

		done       : out std_logic      -- pronto
	);
end entity convolution_module;

architecture arch of convolution_module is
	  -- Usa o kernel constante definido no package
	constant kernel : kernel_array := kernel_edge_detection;
begin
	


end architecture arch; 