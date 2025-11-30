library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity accumulator is
    port(
        clk      : in  std_logic;
        rst      : in  std_logic;
        enable   : in  std_logic;
        data_in  : in  signed(15 downto 0); -- Entrada 12 bits
        data_out : out signed(15 downto 0) -- Saída 16 bits
    );
end entity;

architecture rtl of accumulator is
    signal acc_reg : signed(15 downto 0);
begin

    process(clk, rst)
    begin
        if rst = '1' then
            acc_reg <= (others => '0');
        elsif rising_edge(clk) then
            if enable = '1' then
                acc_reg <= acc_reg + resize(signed(data_in), 16);
            end if;
        end if;
    end process;
    
    data_out <= acc_reg;

end architecture;
