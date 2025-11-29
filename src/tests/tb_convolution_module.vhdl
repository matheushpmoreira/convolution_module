library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.convolution_pack.all;          -- Certifique-se que o tipo kernel_array está aqui

entity tb_convolution_module is
end entity tb_convolution_module;

architecture test of tb_convolution_module is

	-- 1. Configuração
	constant IMG_W : positive := 3;
	constant IMG_H : positive := 3;
	constant T_CLK : time     := 5 ns;

	component convolution_module
		generic(
			img_width  : positive;
			img_height : positive;
			KERNEL     : kernel_array
		);
		port(
			clk          : in  std_logic;
			rst          : in  std_logic;
			enable       : in  std_logic;
			sample_in    : in  std_logic_vector(7 downto 0);
			addr         : out std_logic_vector(address_length(IMG_W, IMG_H) - 1 downto 0);
			sample_out   : out std_logic_vector(7 downto 0); -- AVISO: 8 bits suporta max 255
			sample_ready : out std_logic;
			read_mem     : out std_logic;
			done         : out std_logic
		);
	end component;

	signal clk          : std_logic                    := '0';
	signal rst          : std_logic                    := '1';
	signal enable       : std_logic                    := '0';
	signal sample_in    : std_logic_vector(7 downto 0) := (others => '0');
	signal addr : std_logic_vector(address_length(IMG_W, IMG_H) - 1 downto 0) := (others => '0');
	signal sample_out   : std_logic_vector(7 downto 0);
	signal sample_ready : std_logic := '0';
	signal read_mem     : std_logic := '0';
	signal done         : std_logic := '0';

	-- Memória 3x3
	type memory_t is array (0 to 8) of integer range 0 to 255;

	constant RAM_DATA : memory_t := (
		10, 20, 30,                     -- 0, 1, 2
		40, 50, 60,                     -- 3, 4, 5 (Centro é o indice 4)
		70, 80, 90                      -- 6, 7, 8
	);

begin

	UUT : convolution_module
		generic map(
			img_width  => IMG_W,
			img_height => IMG_H,
			KERNEL     => identity_kernel
		)
		port map(
			clk          => clk,
			rst          => rst,
			enable       => enable,
			sample_in    => sample_in,
			addr         => addr,
			sample_out   => sample_out,
			sample_ready => sample_ready,
			read_mem     => read_mem,
			done         => done
		);

	-- Clock Generation
	p_clk : process
	begin
		clk <= '0';
		wait for T_CLK / 2;
		clk <= '1';
		wait for T_CLK / 2;
	end process;

	-- Simulação da Memória RAM (Leitura Assíncrona baseada no addr)
	p_mem : process(addr)
		variable int_addr : integer;
	begin
		int_addr := to_integer(unsigned(addr));
		if int_addr >= 0 and int_addr < 9 then
			sample_in <= std_logic_vector(to_unsigned(RAM_DATA(int_addr), 8));
		else
			sample_in <= (others => '0'); -- Padding simples se endereço sair do range
		end if;
	end process;

	-- Estímulos de Controle
	p_stim : process
	begin
		rst    <= '1';
		enable <= '0';
		wait for T_CLK * 5;

		rst <= '0';
		wait for T_CLK * 2;

		-- Pulso de enable
		enable <= '1';
		wait for T_CLK;

		-- Espera o processamento acabar
		wait until done = '1';
		enable <= '0';

		report "Fim da Simulacao" severity note;
		wait;
	end process;

	-- Monitor de Saída (Melhorado para ser Síncrono)
	p_monitor : process(clk)
		variable counter : integer := 0;
		variable val_out : integer;
	begin
		if rising_edge(clk) then
			if sample_ready = '1' and enable = '1'  then
				val_out := to_integer(unsigned(sample_out));

				report "Pixel de Saida #" & integer'image(counter) & " | Valor: " & integer'image(val_out);

				counter := counter + 1;
			end if;
		end if;
	end process;

end architecture test;
