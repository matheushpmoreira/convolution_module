library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.convolution_pack.all;

entity tb_bo is
end entity;

architecture tb of tb_bo is

    -- Constantes da simulação
    constant C_IMG_WIDTH  : positive := 8;
    constant C_IMG_HEIGHT : positive := 8;
    constant C_BPP        : positive := 8;

    -- Clock
    signal   clk        : std_logic := '0';
    constant clk_period : time      := 10 ns;

    -- Entradas
    signal R_CW, R_CH, R_CI : std_logic := '0';
    signal E_CW, E_CH, E_CI : std_logic := '0';

    -- Saídas
    signal sample_address                       : unsigned(address_length(C_IMG_WIDTH, C_IMG_HEIGHT) - 1 downto 0);
    signal sample_in                            : unsigned(C_BPP - 1 downto 0) := --test value
        "00011000"; -- 24 decimal
    signal done_width, done_height, done_window : std_logic;

begin

    -- Clock generation
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- DUT (Device Under Test)
    DUT : entity work.bo
        generic map(
            img_width      => C_IMG_WIDTH,
            img_height     => C_IMG_HEIGHT
        )
        port map(
            clk            => clk,
            R_CW           => R_CW,
            R_CH           => R_CH,
            R_CI           => R_CI,
            E_CW           => E_CW,
            E_CH           => E_CH,
            E_CI           => E_CI,
            sample_address => sample_address,
            sample_in      => sample_in,
            done_width     => done_width,
            done_height    => done_height,
            done_window    => done_window
        );

    -- Estímulos
    stim_proc : process
    begin
        -- Reset inicial
        R_CW <= '1';
        R_CH <= '1';
        R_CI <= '1';
        E_CW <= '0';
        E_CH <= '0';
        E_CI <= '0';
        wait for 30 ns;

        R_CW <= '0';
        R_CH <= '0';
        R_CI <= '0';
        wait for 20 ns;

        -- Habilitar contadores gradualmente
        E_CI <= '1';
        wait for 500 ns;

        -- Segunda rodada
        E_CI <= '0';
        E_CW <= '1';
        wait for 500 ns;

        wait;
    end process;

end architecture;
