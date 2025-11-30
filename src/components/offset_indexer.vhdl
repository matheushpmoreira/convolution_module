library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.convolution_pack.all;

entity offset_indexer is
    generic(
        img_width  : positive;
        img_height : positive
    );
    port(
        in_x   : in  unsigned(log2_ceil(img_width) - 1 downto 0);
        in_y : in unsigned(log2_ceil(img_height) - 1 downto 0);
        out_x  : out unsigned(log2_ceil(img_width) - 1 downto 0);
        out_y  : out unsigned(log2_ceil(img_height) -1 downto 0);


        index        : in  unsigned(3 downto 0);
        invalid      : out std_logic
    );
end entity;

architecture rtl of offset_indexer is
begin
    process(in_x, in_y, index)
        variable x_int, y_int   : integer range -1 to img_width + 1;
        variable tx_int, ty_int : integer range -1 to img_height + 1;
    begin
        -- converte entrada
        x_int := to_integer(in_x);
        y_int := to_integer(in_y);

        -- calcula deslocamento baseado no index
        case to_integer(index) is
            when 0 => 
                tx_int := x_int - 1;
                ty_int := y_int - 1;
            when 1 => 
                tx_int := x_int;
                ty_int := y_int - 1;
            when 2 =>
                tx_int := x_int + 1;
                ty_int := y_int - 1;
            when 3 =>
                tx_int := x_int - 1;
                ty_int := y_int;
            when 4 =>
                tx_int := x_int;
                ty_int := y_int;
            when 5 => 
                tx_int := x_int + 1;
                ty_int := y_int;
            when 6 =>
                tx_int := x_int - 1;
                ty_int := y_int + 1;
            when 7 =>
                tx_int := x_int;
                ty_int := y_int + 1;
            when 8 => 
                tx_int := x_int + 1;
                ty_int := y_int + 1;
            when others =>
                tx_int := x_int;
                ty_int := y_int;
        end case;

        -- verifica limites
        if (tx_int < 0) or (tx_int >= img_width) or (ty_int < 0) or (ty_int >= img_height) then
            invalid <= '1';
    
            out_x <= in_x;
            out_y <= in_y;
        else
            invalid <= '0';
            out_x   <= to_unsigned(tx_int, out_x'length);
            out_y   <= to_unsigned(ty_int, out_y'length);
        end if;
    end process;
end architecture;
