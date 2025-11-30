library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.convolution_pack.all;

entity bc is
    port(
        clk          : in  std_logic;
        rst          : in  std_logic;
        enable       : in  std_logic;
        -- Sinais de saída diretos
        read_mem     : out std_logic;
        done         : out std_logic;
        sample_ready : out std_logic;
        -- Sinais de controle e status (Records)
        status       : in  tipo_status;
        comandos     : out tipo_comandos
    );
end entity;

architecture behavior of bc is

    -- Definição dos estados conforme a tabela da imagem
    type tipo_estado is (
        S_IDLE,
        S_CALC_ADDR,
        S_READ_MEM,
        S_CALC_ACC,
        S_INVALID,
        S_WINDOW_DONE,
        S_INC_WIDTH,
        S_INC_HEIGHT,
        S_ALL_DONE
    );

    signal Eatual, Eprox : tipo_estado;

begin

    -- Processo de Registrador de Estado
    process(clk, rst)
    begin
        if rst = '1' then
            Eatual <= S_IDLE;
        elsif rising_edge(clk) then
            Eatual <= Eprox;
        end if;
    end process;

    -- Processo de Lógica de Próximo Estado
    process(Eatual, enable, status)
    begin
        case Eatual is
            -- Estado de Espera
            when S_IDLE =>
                if enable = '1' then
                    Eprox <= S_CALC_ADDR;
                else
                    Eprox <= S_IDLE;
                end if;

            -- 1. Calcula Endereço
            when S_CALC_ADDR =>
                -- Se o endereço calculado for inválido (borda), vai para S_INVALID
                -- Se for válido, vai ler a memória
                if status.done_window = '1' then
                    Eprox <= S_WINDOW_DONE; -- Fim da imagem
                elsif status.invalid = '1' then
                    Eprox <= S_INVALID;
                else
                    Eprox <= S_READ_MEM;
                end if;

            when S_WINDOW_DONE =>
                if status.done_height = '1' and status.done_width = '1' then
                    Eprox <= S_ALL_DONE;    -- Fim da imagem
                elsif status.done_width = '1' then
                    Eprox <= S_INC_HEIGHT; -- Fim da linha, avança altura
                else
                    Eprox <= S_INC_WIDTH; -- Pixel pronto, avança coluna
                end if; 

            -- 2. Lê Memória (apenas se endereço válido)
            when S_READ_MEM =>
                Eprox <= S_CALC_ACC;

            -- 3. Calcula/Acumula (Multiplicação e Soma)
            when S_CALC_ACC =>
                -- Verifica se terminou a janela (kernel 3x3)
                if status.done_window = '1' then
                    Eprox <= S_INC_WIDTH; -- Pixel pronto, avança coluna
                else
                    Eprox <= S_CALC_ADDR; -- Próximo item do kernel
                end if;

            -- Alternativa: Soma Zero (para bordas inválidas)
            when S_INVALID =>
                -- Mesma lógica de looping da janela
                if status.done_window = '1' then
                    Eprox <= S_INC_WIDTH;
                else
                    Eprox <= S_CALC_ADDR;
                end if;

            -- Incrementa Largura (Próximo Pixel da linha)
            when S_INC_WIDTH =>
                if status.done_width = '1' then
                    Eprox <= S_INC_HEIGHT; -- Fim da linha, avança altura
                else
                    Eprox <= S_CALC_ADDR; -- Começa novo pixel na mesma linha
                end if;

            -- Incrementa Altura (Próxima Linha)
            when S_INC_HEIGHT =>
                if status.done_height = '1' then
                    Eprox <= S_ALL_DONE;    -- Fim da imagem
                else
                    Eprox <= S_CALC_ADDR; -- Começa nova linha
                end if;


            -- Estado Final (apenas para sinalizar conclusão e voltar ao idle)
            when S_ALL_DONE =>
                Eprox <= S_IDLE;
            

        end case;
    end process;

    -- Processo de Saídas (Decodificação baseada na tabela fornecida)
    process(Eatual)
    begin
        -- Resetar todos os comandos por padrão para evitar latches
        comandos     <= (others => '0');
        read_mem     <= '0';
        done         <= '0';
        sample_ready <= '0';

        case Eatual is
            when S_IDLE =>
                -- Tabela: R_CW=1, R_CH=1, R_CI=1, R_ACC=1, sample_ready=1, done=1
                comandos.R_CW  <= '1';
                comandos.R_CH  <= '1';
                comandos.R_CI  <= '1';
                comandos.R_ACC <= '1';
                comandos.R_ADDR <= '1';
                comandos.R_MEM  <= '1';

            when S_CALC_ADDR =>
                -- Tabela: E_ADDR=1
                comandos.E_ADDR <= '1';

            when S_READ_MEM =>
                -- Tabela: E_MEM=1, read_mem=1
                comandos.E_MEM <= '1';
                read_mem       <= '1';

            when S_CALC_ACC =>
                -- Tabela: E_CI=1, E_ACC=1
                -- Nota: Aqui E_CI age como incrementador do índice do Kernel (loop interno)
                comandos.E_CI  <= '1';
                comandos.E_ACC <= '1';

            when S_INVALID =>
                -- Tabela: E_CI=1, s_invalid=1
                comandos.R_ADDR  <= '1';
                comandos.E_CI      <= '1';
            
            when S_WINDOW_DONE =>
                -- Tabela: sample_ready=1
                sample_ready   <= '1';
                comandos.R_CI  <= '1';  -- Reseta índice do kernel para o próx pixel

            when S_INC_WIDTH =>
                -- Tabela: E_CW=1, R_CI=1, R_ACC=1, sample_ready=1
                -- Nota: Aqui E_CW incrementa a posição da coluna na imagem
                comandos.E_CW  <= '1';
                comandos.R_CI  <= '1';  -- Reseta índice do kernel para o próx pixel
                comandos.R_ACC <= '1';  -- Reseta acumulador para o próx pixel

            when S_INC_HEIGHT =>
                -- Tabela: E_CH=1, R_CW=1, R_CI=1, R_ACC=1, sample_ready=1
                -- Nota: Aqui E_CH incrementa a linha
                comandos.E_CH  <= '1';
                comandos.R_CW  <= '1';  -- Reseta coluna (voltar p/ esquerda)
                comandos.R_CI  <= '1';
                comandos.R_ACC <= '1';
            when S_ALL_DONE =>
                comandos.R_CW   <= '1';
                comandos.R_CH   <= '1';
                comandos.R_CI   <= '1';
                comandos.R_ACC  <= '1';
                comandos.R_ADDR <= '1';
                comandos.R_MEM  <= '1';
                done <= '1';

        end case;
    end process;

end architecture behavior;
