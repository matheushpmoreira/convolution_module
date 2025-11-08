- bloco offset_calc(base_addr, index)  parametrizado por img_width e img_height
- registrador x_reg
- registrador y_reg

## S_IDLE


    done <= 1 (Sinaliza que o trabalho está feito)
    x_reg <= 0 (Prepara para começar na coluna 0)
    y_reg <= 0 (Prepara para começar na linha 0)
    read_mem <= 0

    Transição:
        Se enable = '1', vai para S_INICIA_PIXEL.
        Senão, fica em S_IDLE.

## S_INICIA_PIXEL 
    
    done <= 0
    index_reg <= 0
    acumulador_reg <= 0 

    Transição:
        Vai para S_PEDE_PIXEL.


## S_PEDE_PIXEL

    calculo_addr_base := (y_reg * G_IMG_WIDTH) + x_reg; 
    window_addr := offset_calc(calculo_addr_base, index_reg);
    sample_address <= window_addr;

    read_mem = 1

    Transição:
        Vai para S_LOOP_CALCULA.


## S_LOOP_CALCULA

        read_mem = 0
        
        sample_in <= (ele é um sinal vindo direto da memoria)

        //cada valor do kernel estará salvo em 9 sinais indexados via mux com o sinal index_reg
        produto = sample_in * kernel[index_reg]

        //Bota o resultado no Acomulador (aqui temos que tomar cuidado com a quantidade de bits para evitar overflow)
        acumulador_reg <= acumulador_reg + produto (Acumula o resultado).

        //incrementa o index em um
        index_reg <= index_reg + 1

    Transição:

        Se index_reg < 8 vai para S_PEDE_PIXEL.

        Se index_reg = 8 (significa que acabamos de ler e calcular o último pixel), vai para S_FINALIZA.

## S_FINALIZA_E_ESCREVE (Estado "Calcula 8 e Escreve")


        resultado_final := clip(acumulador_reg >> N) (Normaliza/Clipa, combinacional).

        sample_out := resultado_final

    Transição:

        Vai para S_PROXIMO_MESMA_LINHA se x_reg < (img_width - 1)
        se não, vai para S_PROXIMO_PULA_LINHA se y_reg < (img_height - 1)
        se não vai para S_IDLE

## S_PROXIMO_MESMA_LINHA
    x_reg <= x_reg + 1

    Transição:
        vai para S_INICIA_PIXEL

## S_PROXIMO_PULA_LINHA
    x_reg <= 0
    y_reg <= y_reg + 1

    Transição:
        vai para S_INICIA_PIXEL


