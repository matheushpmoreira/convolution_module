library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.convolution_pack.all;
use std.env.all;

entity tb_convolution_module is
end entity;

architecture test of tb_convolution_module is

	-- =========================================================================
	-- CONFIGURAÇÃO DO HARDWARE (Deve ser fixo na compilação)
	-- =========================================================================
	constant DUT_W : integer := 200;
	constant DUT_H : integer := 200;
	constant T_CLK : time    := 10 ns;

	-- Definição de Tipo para Arquivo Binário (Byte a Byte)
	type binary_file_t is file of character;

	-- Sinais
	signal clk          : std_logic                    := '0';
	signal rst          : std_logic                    := '1';
	signal enable       : std_logic                    := '0';
	signal sample_in    : std_logic_vector(7 downto 0) := (others => '0');
	signal addr         : std_logic_vector(address_length(DUT_W, DUT_H) - 1 downto 0);
	signal sample_out   : std_logic_vector(7 downto 0);
	signal sample_ready : std_logic;
	signal done         : std_logic;



	signal done_loading : std_logic := '0';

	-- Memória RAM para armazenar a imagem lida
	type   ram_t    is array (0 to (DUT_W * DUT_H) - 1) of integer range 0 to 255;
	signal RAM_DATA : ram_t := (others => 0);

	-- Componente (Seu módulo original)
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
			addr         : out std_logic_vector;
			sample_out   : out std_logic_vector(7 downto 0);
			sample_ready : out std_logic;
			read_mem     : out std_logic;
			done         : out std_logic
		);
	end component;

begin

	-- Instância do Módulo
	UUT : convolution_module
		generic map(
			img_width  => DUT_W,
			img_height => DUT_H,
			KERNEL     => kernel_edge_detection -- ou identity_kernel
		)
		port map(
			clk          => clk,
			rst          => rst,
			enable       => enable,
			sample_in    => sample_in,
			addr         => addr,
			sample_out   => sample_out,
			sample_ready => sample_ready,
			read_mem     => open,
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

	-- =========================================================================
	-- PROCESSO 1: LER ARQUIVO BINÁRIO (HEADER + PIXELS)
	-- =========================================================================
	p_load_file : process
		file     img_file : binary_file_t;
		variable char_v   : character;
		variable status   : file_open_status;
	begin
		-- Abre arquivo .bin REAL (bytes crus)
		file_open(status, img_file, "./examples/input_image.bin", read_mode);

		if status /= open_ok then
			report "ERRO CRITICO: Nao foi possivel abrir input_image.bin" severity failure;
		end if;

		report "Lendo input_image.bin...";

		-- Lê cada byte e converte para inteiro 0..255
		for i in 0 to (DUT_H * DUT_W) - 1 loop
			if not endfile(img_file) then
				read(img_file, char_v);
				RAM_DATA(i) <= character'pos(char_v); -- byte → int
			else
				RAM_DATA(i) <= 0;       -- fallback
			end if;
		end loop;

		file_close(img_file);

		report "Carga da memoria concluida.";
		done_loading <= '1';

		wait;                           -- Executa uma vez
	end process;

	-- Emulação da RAM (Responde ao addr do módulo)
	p_mem : process(addr, RAM_DATA)
		variable idx : integer;
	begin
		idx := to_integer(unsigned(addr));
		if idx >= 0 and idx < (DUT_W * DUT_H) then
			sample_in <= std_logic_vector(to_unsigned(RAM_DATA(idx), 8));
		else
			sample_in <= (others => '0');
		end if;
	end process;

	-- Controle de Reset e Enable
	p_stim : process
	begin
		rst    <= '1';
		enable <= '0';
		
		wait until done_loading = '1';

		rst <= '0';
		wait for T_CLK * 2;

		enable <= '1';

		wait for T_CLK * 2;
		enable <= '0';

		wait until done = '1';

		report "PROCESSAMENTO FINALIZADO" severity note;

		wait;                           -- Executa uma vez
		
	end process;

	-- =========================================================================
	-- PROCESSO 2: ESCREVER SAÍDA (BINÁRIO PURO, SEM HEADER)
	-- =========================================================================
	p_write_output : process
		file     out_file : binary_file_t;
		variable char_v   : character;
		variable status   : file_open_status;
		variable val_int  : integer;
	begin
		-- 1. Abre o arquivo
		file_open(status, out_file, "./examples/output_image.bin", write_mode);
		if status /= open_ok then
			report "ERRO CRITICO: Nao foi possivel criar output_image.bin" severity failure;
		end if;

		report "Arquivo aberto. Aguardando dados..." severity note;

		loop
			wait until rising_edge(clk);

			-- Seus sinais precisam estar em '1' aqui
			if sample_ready = '1' then

				-- 2. DEBUG: Reporta ANTES de tentar converter (para ver se entrou)
				-- report "Entrou no IF. Sample_out bruto: " & to_string(sample_out) severity note;

				-- 3. Converte para inteiro
				-- Se sample_out for "UUUUUUUU", o to_integer pode dar erro fatal.
				if is_x(sample_out) then
					val_int := 0;       -- Proteção contra indefinidos
					report "AVISO: Sample_out indefinido (X ou U), forçando 0" severity warning;
				else
					val_int := to_integer(unsigned(sample_out));
				end if;

				-- 4. PROTEÇÃO (Clamp): O valor PRECISA ser 0 a 255 para virar char
				if val_int > 255 then
					val_int := 255;
				end if;
				if val_int < 0 then
					val_int := 0;
				end if;

				-- 5. Converte e Escreve
				char_v := character'val(val_int);
				write(out_file, char_v);

			end if;

			-- 6. Fecha o arquivo
			if done = '1' then
				file_close(out_file);
				report "Sinal DONE recebido. Arquivo fechado e salvo." severity note;
				stop;
			end if;
		end loop;
	end process;

end architecture;
