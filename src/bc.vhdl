library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.convolution_pack.all;

-- Bloco de Controle (BC) do circuito SAD.
-- Responsável por gerar os sinais de controle para o bloco operativo (BO),
-- geralmente por meio de uma FSM.

entity bc is
    port(
        clk          : in  std_logic;   -- clock (sinal de relógio)
        rst          : in  std_logic;   -- reset assíncrono ativo em nível alto
        enable       : in  std_logic;
        
        -- Sinais de início pronto e leitura de memória
        read_mem     : out std_logic;
        done         : out std_logic;
        sample_ready : out std_logic;
        
        --- Sinais de controle e status
        status       : in  tipo_status;
        comandos     : out tipo_comandos
    );
end entity;
-- Não altere o nome da entidade nem da arquitetura!

architecture behavior of bc is

    type tipo_estado is (S0, S1, S2, S3, S4, S5);

    signal Eatual, Eprox : tipo_estado;

begin

    process(clk, rst)
    begin
        if rst = '1' then
            Eatual <= S0;
        elsif rising_edge(clk) then
            Eatual <= Eprox;
        end if;
    end process;

    process(Eatual, enable)
    begin
        case Eatual is
            when S0 =>
                if enable = '1' then
                    Eprox <= S1;
                else
                    Eprox <= S0;
                end if;
            when S1 =>
                Eprox <= S2;
            when S2 =>
                Eprox <= S3;
            when S3 =>
                Eprox <= S4;
            when S4 =>
                Eprox <= S2;
            when S5 =>
                Eprox <= S0;
        end case;
    end process;

    process(Eatual)
    begin
        --default
        read_mem <= '0';
        done   <= '0';
        comandos <= (others => '0');

        case Eatual is
            when S0 =>
                done <= '1';
            when S1 =>
                comandos <= (
                    others => '0'
                );
            when S2 =>
                null;
            when S3 =>
                comandos <= (
                    others => '0'
                );
            when S4 =>
                comandos <= (
                    others => '0'
                );
            when S5 =>
                comandos <= (
                    others => '0'
                );
        end case;
    end process;

end architecture;
