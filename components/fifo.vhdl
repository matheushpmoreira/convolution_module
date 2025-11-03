library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fifo is
    generic(
        G_DEPTH : natural := 256;
        G_WIDTH : natural := 8
    );
    port(
        clk    : in  std_logic;         -- Sinal do relógio.
        rst    : in  std_logic;         -- Sinal de reset assíncrono, ativo alto (padrão do projeto).
        enable : in  std_logic;         -- Sinal de carga, só quando for 1 o dado da entrada é carregado.
        din    : in  unsigned(G_WIDTH - 1 downto 0);
        dout   : out unsigned(G_WIDTH - 1 downto 0)
    );
end entity fifo;

architecture arch of fifo is

    -- memory signal
    type   t_bram is array (0 to G_DEPTH - 1) of unsigned(G_WIDTH - 1 downto 0);
    signal mem    : t_bram;

    -- address counter
    signal addr_cnt : integer range 0 to G_DEPTH - 1;

begin

    process(clk, rst)
    begin
        if rst = '1' then
            addr_cnt <= 0;
            dout     <= (others => '0');

        elsif rising_edge(clk) then

            if enable = '1' then
                mem(addr_cnt) <= din;
                dout          <= mem(addr_cnt);

                if addr_cnt = G_DEPTH - 1 then
                    addr_cnt <= 0;
                else
                    addr_cnt <= addr_cnt + 1;
                end if;

            end if;
        end if;
    end process;

end architecture arch;
