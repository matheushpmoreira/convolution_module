library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity convolution_module is
    generic(
        -- G_IMG_WIDTH é o 'B' da sua imagem (largura)
        -- Essencial para o pipeline de validade do BC
        G_IMG_WIDTH : natural := 640
    );
    port(
        -- === Sinais Globais (Controle) ===
        clk            : in  std_logic; -- Clock principal
        rst            : in  std_logic; -- Reset (ativo-alto, como no seu FIFO)

        -- === Interface de Streaming de Entrada (Pixel) ===
        pixel_in       : in  unsigned(7 downto 0); -- Pixel de 8 bits
        data_valid_in  : in  std_logic; -- '1' se pixel_in é válido

        -- === Interface de Entrada (Kernel 3x3) ===
        -- Estes são os 9 valores do kernel, "amarrados" (wired)
        -- ao Bloco Operativo.
        k_in_00        : in  unsigned(7 downto 0);
        k_in_01        : in  unsigned(7 downto 0);
        k_in_02        : in  unsigned(7 downto 0);
        k_in_10        : in  unsigned(7 downto 0);
        k_in_11        : in  unsigned(7 downto 0);
        k_in_12        : in  unsigned(7 downto 0);
        k_in_20        : in  unsigned(7 downto 0);
        k_in_21        : in  unsigned(7 downto 0);
        k_in_22        : in  unsigned(7 downto 0);
        -- === Interface de Streaming de Saída (Resultado) ===
        -- Saída com a precisão completa (antes de normalizar/clipar)
        pixel_out_full : out unsigned(19 downto 0);
        -- Saída final de 8 bits (normalizada/clipada)
        pixel_out_8bit : out unsigned(7 downto 0);
        -- '1' se as saídas são válidas
        data_valid_out : out std_logic
    );
end entity convolution_module;
