library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.convolution_pack.all;

entity convolution_module is
	generic(
		-- obrigatório ---
		img_width    : positive := 256; -- número de valores numa linha de imagem
		img_height   : positive := 256; -- número de linhas de valores na imagem
		KERNEL       : kernel_array := kernel_edge_detection
	);
	
	port(
		clk          : in  std_logic;     -- ck
		rst          : in  std_logic;     -- reset
		enable       : in  std_logic;     -- iniciar operação
		sample_in    : in  std_logic_vector(7 downto 0);

		addr         : out std_logic_vector(address_length(img_width, img_height) - 1 downto 0);
		sample_out   : out std_logic_vector(7 downto 0);
      sample_ready : out std_logic;     -- amostra pronta
		read_mem     : out std_logic;     -- ler memória
		done         : out std_logic      -- pronto
	);

end entity convolution_module;

architecture arch of convolution_module is
	signal status : tipo_status;
	signal comandos : tipo_comandos;
	signal addr_bo : unsigned(address_length(img_width, img_height) - 1 downto 0);
	signal sample_out_bo : unsigned(7 downto 0);
begin
	
	BC: entity work.bc
		port map(
			clk => clk,
			rst => rst,
			enable => enable,

			read_mem => read_mem,
			sample_ready => sample_ready,
			done => done,

			status => status,
			comandos => comandos
		);

	BO: entity work.bo
		generic map(
			img_width  => img_width,
			img_height => img_height,
			KERNEL     => KERNEL
		)
		port map(
			clk => clk,
			sample_in => unsigned(sample_in),

			addr => addr_bo,
			sample_out => sample_out_bo,

			status => status,
			comandos => comandos
		);
		
		addr <= std_logic_vector(addr_bo);
		sample_out <= std_logic_vector(sample_out_bo);

end architecture arch; 