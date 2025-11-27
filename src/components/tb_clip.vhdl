library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_clip is
end tb_clip;

architecture sim of tb_clip is

    constant N_TB    : positive := 8;
    
    constant LOW_TB  : integer := -20;
    constant HIGH_TB : integer := 20;

    signal s_value         : signed(N_TB - 1 downto 0) := (others => '0');
    signal s_clipped_value : signed(N_TB - 1 downto 0);

begin

    DUT: entity work.clip
    generic map (
        N    => N_TB,
        LOW  => LOW_TB,
        HIGH => HIGH_TB
    )
    port map (
        value         => s_value,
        clipped_value => s_clipped_value
    );

    p_stimulus: process
    begin
        ------------------------------------------------------------
        -- Caso 1: Dentro do intervalo
        -- Entrada: 0 | Esperado: 0
        ------------------------------------------------------------
        s_value <= to_signed(0, N_TB);
        wait for 20 ns;
        assert (s_clipped_value = to_signed(0, N_TB))
        report "ERRO Caso 1: 0 esta dentro do intervalo, nao deveria mudar." severity error;

        ------------------------------------------------------------
        -- Caso 2: Dentro do intervalo
        -- Entrada: 15 | Esperado: 15
        ------------------------------------------------------------
        s_value <= to_signed(15, N_TB);
        wait for 20 ns;
        assert (s_clipped_value = to_signed(15, N_TB))
        report "ERRO Caso 2: 15 esta dentro do intervalo (-20 a 20)." severity error;

        ------------------------------------------------------------
        -- Caso 3: Acima do limite
        -- Entrada: 50 | Esperado: 20
        ------------------------------------------------------------
        s_value <= to_signed(50, N_TB);
        wait for 20 ns;
        assert (s_clipped_value = to_signed(HIGH_TB, N_TB))
        report "ERRO Caso 3: Entrada 50 deveria ser cortada para 20." severity error;

        ------------------------------------------------------------
        -- Caso 4: Abaixo do limite
        -- Entrada: -50 | Esperado: -20
        ------------------------------------------------------------
        s_value <= to_signed(-50, N_TB);
        wait for 20 ns;
        assert (s_clipped_value = to_signed(LOW_TB, N_TB))
        report "ERRO Caso 4: Entrada -50 deveria ser cortada para -20." severity error;

        ------------------------------------------------------------
        -- Caso 5: Teste de Borda Exata
        -- Entrada: -21 | Esperado: -20
        ------------------------------------------------------------
        s_value <= to_signed(-21, N_TB);
        wait for 20 ns;
        assert (s_clipped_value = to_signed(LOW_TB, N_TB))
        report "ERRO Caso 5: Borda inferior falhou." severity error;

        report "Fim dos testes do clip." severity note;
        wait;
    end process;

end sim;