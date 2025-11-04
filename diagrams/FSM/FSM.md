### criar bloco chamado calc_offset ele vai receber o calculo (r_reg * G_IMG_WIDTH) + c_reg, um index, e as dimensões da imagem e calcular um offset para o proximo ciclo

- registrador r_reg (row) 
- registrador c_reg (column)


## S_IDLE (Estado "Pronto")

    Função: Ponto de partida. Espera o sinal de enable para começar.

    Ações (no clock):

        ready <= '1' (Sinaliza que está pronto para começar)

        done <= '0' (Sinaliza que o trabalho não está feito)

        r_reg <= 0 (Prepara para começar na linha 1, não pulando a borda)

        c_reg <= 0 (Prepara para começar na coluna 1, não pulando a borda)

        ram_saida_we <= '0' (Garante que a escrita na RAM de saída está desligada)

    Transição:

        Se enable = '1', vai para S_INICIA_PIXEL.

        Senão, fica em S_IDLE.

## S_INICIA_PIXEL (Estado "Prepara e Pede 0")

    Função: Prepara os registros para um novo pixel de saída. Faz o cálculo "caro" (r*B+c) e já pede o primeiro pixel da janela (index=0).

    Ações (no clock):

        ready <= '0' (Sinaliza que está ocupado)

        acumulador_reg <= (others => '0') (Zera a soma)

        index_reg <= 0 (Reseta o contador do loop interno)

        addr_base_reg <= (r_reg * G_IMG_WIDTH) + c_reg (Calcula e salva o endereço base)

        offset_end = offset_calc(addr_base_reg, 0, G_IMG_WIDTH, G_IMG_HEIGHT)

        samples_mem_addr <= offset_end

    Transição:

        Vai para S_LOOP_CALCULA.

## S_LOOP_CALCULA (Estado "Calcula [i] e Pede [i+1]")

    Função: O coração do loop. Roda 8 vezes (para index_reg de 0 a 7).

    Ações (no clock):

        pixel_da_janela_reg <= rom_samples[offset_end] (O pixel index que foi pedido no ciclo anterior chegou. Ele é salvo).

        produto = pixel_da_janela_reg * valor_do_kernel (Calcula usando o pixel salvo e o kernel[index] instantâneo).

        acumulador_reg <= acumulador_reg + produto (Acumula o resultado).

        offset_end = offset_calc(index_reg + 1) (Usa o MUX para calcular o endereço do próximo pixel).

        samples_mem_addr <= offset_end (Pede o próximo pixel, index+1).

        index_reg <= index_reg + 1 (Avança o contador do loop).

    Transição:

        Se index_reg < 7 (ou seja, o índice atual é 0-6), fica em S_LOOP_CALCULA.

        Se index_reg = 7 (significa que acabamos de pedir o último pixel, o 8), vai para S_FINALIZA_E_ESCREVE.

## S_FINALIZA_E_ESCREVE (Estado "Calcula 8 e Escreve")

    Função: O loop de 8 ciclos acabou. O 9º (e último) pixel chegou. Este estado faz o último cálculo e escreve o resultado na RAM de saída.

    Ações (no clock):

        pixel_da_janela_reg <= dado_da_rom_samples (O último pixel, index=8, chegou. Ele é salvo).

        produto_final = pixel_da_janela_reg * kernel_mem[8] (Cálculo final. index_reg agora é 8).

        resultado_bruto = acumulador_reg + produto_final (Soma final, combinacional).

        resultado_final = clip(resultado_bruto >> N) (Normaliza/Clipa, combinacional).

        ram_saida_addr <= addr_base_reg (O endereço de saída é o (r*B+c) que já salvamos).

        ram_saida_data <= resultado_final (Coloca o dado na porta de saída).

        ram_saida_we <= '1' (Liga a escrita!).

    Transição:

        Vai para S_PROXIMO_PIXEL.

## S_PROXIMO_PIXEL (Estado "Avança")

    Função: Desliga a escrita e move os contadores r_reg e c_reg para o próximo pixel de saída, pulando as bordas.

    Ações (no clock):

        ram_saida_we <= '0' (Desliga a escrita!).

        (Lógica para incrementar c_reg):

            if c_reg < (G_IMG_WIDTH - 2) then

                c_reg <= c_reg + 1

            else (Chegou na borda direita)

                c_reg <= 1 (Volta para a borda esquerda)

                (Lógica para incrementar r_reg):

                    if r_reg < (G_IMG_HEIGHT - 2) then

                        r_reg <= r_reg + 1

                    else (Chegou na última linha)

                        r_reg <= 1 (Reseta a linha)

                        done <= '1' (Sinaliza que a imagem inteira terminou)

    Transição:

        Se done = '1' (foi o último pixel), vai para S_IDLE.

        Senão, vai para S_INICIA_PIXEL (para começar o próximo pixel).