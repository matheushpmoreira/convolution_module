library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_signed_adder is
end tb_signed_adder;

architecture sim of tb_signed_adder is

    constant N_TB : positive := 8;

    signal s_input_a : signed(N_TB - 1 downto 0) := (others => '0');
    signal s_input_b : signed(N_TB - 1 downto 0) := (others => '0');
    signal s_sum     : signed(N_TB downto 0);

begin

    DUT: entity work.signed_adder
    generic map (N => N_TB)
    port map (
        input_a => s_input_a,
        input_b => s_input_b,
        sum     => s_sum
    );

    p_stimulus: process
    begin
        ----------------------------------------------------------------
        -- Caso 1: 10 + 5 = 15
        ----------------------------------------------------------------
        s_input_a <= to_signed(10, N_TB);
        s_input_b <= to_signed(5, N_TB);
        wait for 20 ns; 
        
        assert (s_sum = to_signed(15, N_TB + 1))
        report "ERRO no Caso 1: 10 + 5 deveria ser 15"
        severity error;

        ----------------------------------------------------------------
        -- Caso 2: 20 + (-5) = 15
        ----------------------------------------------------------------
        s_input_a <= to_signed(20, N_TB);
        s_input_b <= to_signed(-5, N_TB);
        wait for 20 ns;

        assert (s_sum = to_signed(15, N_TB + 1))
        report "ERRO no Caso 2: 20 + (-5) deveria ser 15"
        severity error;

        ----------------------------------------------------------------
        -- Caso 3: -10 + (-20) = -30
        ----------------------------------------------------------------
        s_input_a <= to_signed(-10, N_TB);
        s_input_b <= to_signed(-20, N_TB);
        wait for 20 ns;

        assert (s_sum = to_signed(-30, N_TB + 1))
        report "ERRO no Caso 3: -10 + (-20) deveria ser -30"
        severity error;

        ----------------------------------------------------------------
        -- Caso 4: Overflow Positivo (127 + 1 = 128)
        ----------------------------------------------------------------
        s_input_a <= to_signed(127, N_TB);
        s_input_b <= to_signed(1, N_TB);
        wait for 20 ns;

        assert (s_sum = to_signed(128, N_TB + 1))
        report "ERRO no Caso 4: 127 + 1 deveria ser 128"
        severity error;

        ----------------------------------------------------------------
        -- Caso 5: Overflow Negativo (-128 + (-1) = -129)
        ----------------------------------------------------------------
        s_input_a <= to_signed(-128, N_TB);
        s_input_b <= to_signed(-1, N_TB);
        wait for 20 ns;

        assert (s_sum = to_signed(-129, N_TB + 1))
        report "ERRO no Caso 5: -128 + (-1) deveria ser -129"
        severity error;

        report "Fim dos testes do signed_adder." severity note;
        wait;
    end process;

end sim;