library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.convolution_pack.all;

entity tb_convolution_module is
end entity tb_convolution_module;

architecture test of tb_convolution_module is

	-- 1. Configuração 3x3
	constant IMG_W : positive := 3;
	constant IMG_H : positive := 3;
	constant T_CLK : time     := 10 ns;

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
			sample_out   : out std_logic_vector(7 downto 0);
			sample_ready : out std_logic;
			read_mem     : out std_logic;
			done         : out std_logic
		);
	end component;

	signal clk          : std_logic                    := '0';
	signal rst          : std_logic                    := '1';
	signal enable       : std_logic                    := '0';
	signal sample_in    : std_logic_vector(7 downto 0) := (others => '0');
	signal addr         : std_logic_vector(address_length(IMG_W, IMG_H) - 1 downto 0);
	signal sample_out   : std_logic_vector(7 downto 0);
	signal sample_ready : std_logic;
	signal read_mem     : std_logic;
	signal done         : std_logic;

	-- Memória 3x3 = 9 posições
	type memory_t is array (0 to 8) of integer range 0 to 255;

	-- CENÁRIO DE TESTE:
	-- Apenas o pixel do centro (índice 4) tem valor 30. O resto é 0.
	constant RAM_DATA : memory_t := (
		3, 4, 1,                        -- Linha 0
		244, 2, 1,                       -- Linha 1 (Centro = 30)
		7, 1, 3                          -- Linha 2
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

	-- Clock
	p_clk : process
	begin
		clk <= '0';
		wait for T_CLK / 2;
		clk <= '1';
		wait for T_CLK / 2;
	end process;

	-- Memória Simples
	p_mem : process(addr)
		variable int_addr : integer;
	begin
		int_addr := to_integer(unsigned(addr));
		if int_addr < 9 then
			sample_in <= std_logic_vector(to_unsigned(RAM_DATA(int_addr), 8));
		else
			sample_in <= (others => '0');
		end if;
	end process;

	-- Controle
	p_stim : process
	begin
		rst    <= '1';
		enable <= '0';
		wait for T_CLK * 8;

		rst <= '0';
		wait for T_CLK * 4;

		enable <= '1';

		wait until done = '1';
		wait for T_CLK * 5;

		report "Fim do Teste 3x3" severity note;
		wait;
	end process;

	-- Monitor de Saída
	p_monitor : process(clk)
		variable i : integer := 0;
	begin
		if rising_edge(clk) and sample_ready = '1' then
			report "Pixel [" & integer'image(i) & "] Saiu: " & integer'image(to_integer(unsigned(sample_out)));
			i := i + 1;
		end if;
	end process;

end architecture test;
