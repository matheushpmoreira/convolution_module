library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom_indexer is
    generic(
            img_width : positive;
            img_height : positive
        );
    port(
        
        clk            : in  std_logic; -- Clock principal
        rst            : in  std_logic -- Reset (ativo-alto)

    );
end entity rom_indexer;
