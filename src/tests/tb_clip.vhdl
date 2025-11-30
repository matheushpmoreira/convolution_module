library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_clip is
    -- Testbench não tem portas
end tb_clip;

architecture sim of tb_clip is

    -- Componente a ser testado (UUT)
    component clip is
        generic(
            LOW  : integer := 0;
            HIGH : integer := 255
        );
        port(
            value         : in  signed(15 downto 0);
            clipped_value : out unsigned(7 downto 0)
        );
    end component;

    -- Sinais de conexão
    signal s_value         : signed(15 downto 0) := (others => '0');
    signal s_clipped_value : unsigned(7 downto 0);

    -- Constante de tempo
    constant T_DELAY : time := 10 ns;

begin

    -- Instanciação do UUT
    uut : clip
        generic map(
            LOW  => 0,
            HIGH => 255
        )
        port map(
            value         => s_value,
            clipped_value => s_clipped_value
        );

    -- Processo de estímulo e verificação
    p_stim : process
        variable v_expected : integer;
    begin
        report "Iniciando Teste do Clip..." severity note;

        -- Loop varrendo de -20 até 300 para cobrir todas as condições:
        -- 1. Valores negativos (deve sair 0)
        -- 2. Valores normais (0 a 255)
        -- 3. Valores overflow (acima de 255, deve sair 255)

        for i in -20 to 300 loop
            s_value <= to_signed(i, 16);

            wait for T_DELAY;

            -- Lógica de verificação (O que esperamos?)
            if i < 0 then
                v_expected := 0;
            elsif i > 255 then
                v_expected := 255;
            else
                v_expected := i;
            end if;

            -- Auto-checagem (Assert)
            assert to_integer(s_clipped_value) = v_expected
            report "Erro! Entrada: " & integer'image(i) & " | Saida Obtida: " & integer'image(to_integer(s_clipped_value)) & " | Esperado: " & integer'image(v_expected)
            severity error;
        end loop;

        report "Simulacao concluida com sucesso!" severity note;
        wait;                           -- Para a simulação
    end process;

end sim;
