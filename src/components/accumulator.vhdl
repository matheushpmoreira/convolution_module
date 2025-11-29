library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity accumulator is
    port(
        clk      : in  std_logic;
        rst      : in  std_logic;       -- Reset (Assíncrono, ligado ao R_ACC da sua FSM)
        enable   : in  std_logic;       -- Enable (Ligado ao E_ACC da sua FSM)
        data_in  : in  signed(15 downto 0); -- Entrada 12 bits
        data_out : out signed(15 downto 0) -- Saída 16 bits
    );
end entity;

architecture rtl of accumulator is
    -- Sinal interno do tipo SIGNED para facilitar a matemática
    signal acc_reg : signed(15 downto 0);
begin

    process(clk, rst)
    begin
        if rst = '1' then
            -- Zera o acumulador
            acc_reg <= (others => '0');
        elsif rising_edge(clk) then
            if enable = '1' then
                -- O resize expande o data_in de 12 para 16 bits mantendo o sinal
                acc_reg <= acc_reg + resize(signed(data_in), 16);
            end if;
        end if;
    end process;

    -- Converte de volta para std_logic_vector para a saída
    data_out <= acc_reg;

end architecture;
