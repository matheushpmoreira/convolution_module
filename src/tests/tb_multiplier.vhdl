library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_multiplier is
end entity tb_multiplier;

architecture sim of tb_multiplier is

    -- Component under test
    component multiplier is
        port(
            a_signed   : in  signed(3 downto 0);
            b_unsigned : in  unsigned(7 downto 0);
            result_out : out signed(15 downto 0)
        );
    end component;

    signal a_signed_s   : signed(3 downto 0);
    signal b_unsigned_s : unsigned(7 downto 0);
    signal result_s     : signed(15 downto 0);

begin

    uut : multiplier
        port map(
            a_signed   => a_signed_s,
            b_unsigned => b_unsigned_s,
            result_out => result_s
        );

    stimulus : process
        -- função auxiliar para conferência com integer
        function ref_mult(a : signed(3 downto 0); b : unsigned(7 downto 0)) return integer is
        begin
            return to_integer(a) * to_integer(b);
        end function;
    begin
        ----------------------------------------------------------------------
        -- Teste 1: A = 0
        ----------------------------------------------------------------------
        a_signed_s   <= to_signed(0, 4);
        b_unsigned_s <= to_unsigned(100, 8);
        wait for 10 ns;
        assert result_s = to_signed(ref_mult(a_signed_s, b_unsigned_s), 16)
        report "Erro: 0 * 100" severity error;

        ----------------------------------------------------------------------
        -- Teste 2: A positivo
        ----------------------------------------------------------------------
        a_signed_s   <= to_signed(5, 4); -- +5
        b_unsigned_s <= to_unsigned(10, 8);
        wait for 10 ns;
        assert result_s = to_signed(ref_mult(a_signed_s, b_unsigned_s), 16)
        report "Erro: 5 * 10" severity error;

        ----------------------------------------------------------------------
        -- Teste 3: A negativo
        ----------------------------------------------------------------------
        a_signed_s   <= to_signed(-3, 4);
        b_unsigned_s <= to_unsigned(20, 8);
        wait for 10 ns;
        assert result_s = to_signed(ref_mult(a_signed_s, b_unsigned_s), 16)
        report "Erro: -3 * 20" severity error;

        ----------------------------------------------------------------------
        -- Teste 4: Máximo positivo do a_signed (+7)
        ----------------------------------------------------------------------
        a_signed_s   <= to_signed(7, 4);
        b_unsigned_s <= to_unsigned(255, 8);
        wait for 10 ns;
        assert result_s = to_signed(ref_mult(a_signed_s, b_unsigned_s), 16)
        report "Erro: 7 * 255" severity error;

        ----------------------------------------------------------------------
        -- Teste 5: Mínimo negativo do a_signed (-8)
        ----------------------------------------------------------------------
        a_signed_s   <= to_signed(-8, 4);
        b_unsigned_s <= to_unsigned(255, 8);
        wait for 10 ns;
        assert result_s = to_signed(ref_mult(a_signed_s, b_unsigned_s), 16)
        report "Erro: -8 * 255" severity error;

        ----------------------------------------------------------------------
        -- Teste 6: B = 0
        ----------------------------------------------------------------------
        a_signed_s   <= to_signed(-5, 4);
        b_unsigned_s <= to_unsigned(0, 8);
        wait for 10 ns;
        assert result_s = to_signed(ref_mult(a_signed_s, b_unsigned_s), 16)
        report "Erro: -5 * 0" severity error;

        ----------------------------------------------------------------------
        -- Teste 7: varrendo valores (loop)
        ----------------------------------------------------------------------
        for a in -8 to 7 loop
            for b in 0 to 20 loop
                a_signed_s   <= to_signed(a, 4);
                b_unsigned_s <= to_unsigned(b, 8);
                wait for 1 ns;

                assert result_s = to_signed(a * b, 16)
                report "Erro no loop: " & integer'image(a) & " * " & integer'image(b)
                severity error;
            end loop;
        end loop;

        ----------------------------------------------------------------------
        -- Finalização
        ----------------------------------------------------------------------
        report "Todos os testes passaram com sucesso!" severity note;
        wait;

    end process;

end architecture sim;
