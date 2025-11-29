library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_accumulator is
end entity;

architecture sim of tb_accumulator is

    -- Sinais para conectar ao componente
    signal clk      : std_logic                     := '0';
    signal rst      : std_logic                     := '0';
    signal enable   : std_logic                     := '0';
    signal data_in  : signed(15 downto 0) := (others => '0');
    signal data_out : signed(15 downto 0);

    -- Definição do período do clock
    constant CLK_PERIOD : time := 10 ns;

begin

    -- Instanciação do DUT (Device Under Test)
    DUT : entity work.accumulator
        port map(
            clk      => clk,
            rst      => rst,
            enable   => enable,
            data_in  => data_in,
            data_out => data_out
        );

    -- Gerador de Clock
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- Processo de Estímulo
    stim_proc : process
    begin
        -- 1. Reset Inicial
        rst <= '1';
        wait for CLK_PERIOD * 2;
        rst <= '0';
        wait for CLK_PERIOD;

        -- CASO 1: Somar valor Máximo Positivo 9 vezes
        -- Máximo 12 bits signed = 2047 (0111...111)
        data_in <= to_signed(2047, 16);
        enable  <= '1';

        -- Loop de 9 clocks
        for i in 1 to 9 loop
            wait for CLK_PERIOD;
        end loop;

        -- Desabilita enable e verifica resultado
        -- Esperado: 2047 * 9 = 18423
        enable <= '0';
        wait for CLK_PERIOD * 2;

        -- Reset antes do próximo teste (simulando o R_ACC da FSM)
        rst <= '1';
        wait for CLK_PERIOD;
        rst <= '0';

        -- CASO 2: Somar valores Negativos
        -- Valor -1000
        data_in <= to_signed(-1000, 16);
        enable  <= '1';

        -- Soma 2 vezes (-1000 + -1000 = -2000)
        wait for CLK_PERIOD;
        wait for CLK_PERIOD;

        enable <= '0';

        wait;                           -- Fim da simulação
    end process;

end architecture;
