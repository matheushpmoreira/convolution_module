library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.convolution_pack.all;

entity tb_convolution_module is
end tb_convolution_module;

architecture sim of tb_convolution_module is

    -- Escolhi os valores 3 para a o teste pois é a menor dimensão que contém uma amostra
    -- mais centrada, que não esteja na borda
    constant IMG_WIDTH_TB  : positive := 3;
    constant IMG_HEIGHT_TB : positive := 3;
    constant KERNEL_TB     : kernel_array := kernel_edge_detection;
	 
	 type img_data is array (0 to 8) of integer range 0 to 255; 
	 
	 constant IMG : img_data := (
		  2, 4, 8,
		  4, 8, 16,
		  8, 16, 32
	 );
	 
	 constant CONVOLUTED : img_data := (
		  0, 0, 28,
		  0, 0, 44,
		  28, 44, 184
	 );

    signal s_clk          : std_logic := '0';
    signal s_rst          : std_logic;
    signal s_enable       : std_logic;
    signal s_sample_in    : std_logic_vector(7 downto 0);
    signal s_addr         : std_logic_vector(address_length(IMG_WIDTH_TB, IMG_HEIGHT_TB) - 1 downto 0);
    signal s_sample_out   : std_logic_vector(7 downto 0);
    signal s_sample_ready : std_logic;
    signal s_read_mem     : std_logic;
    signal s_done         : std_logic;

begin

    DUT: entity work.convolution_module
    generic map (
		img_width  => IMG_WIDTH_TB,
		img_height => IMG_HEIGHT_TB,
		KERNEL     => KERNEL_TB
    )
    port map (
		clk          => s_clk,
		rst          => s_rst,
		enable       => s_enable,
		sample_in    => s_sample_in,

		addr         => s_addr,
		sample_out   => s_sample_out,
      sample_ready => s_sample_ready,
		read_mem     => s_read_mem,
		done         => s_done
    );
	 
	 s_clk <= not s_clk after 20 ns;

    p_stimulus: process(s_clk)
    begin
	 
			if (s_sample_ready = '1') then
				assert(s_sample_out = std_logic_vector(to_unsigned(CONVOLUTED(to_integer(unsigned(s_addr))), 8)))
				report "ERRO" severity error;
			end if;
    end process;

end sim;