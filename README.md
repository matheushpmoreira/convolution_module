# AP3-02208B-Grupo-B

## Módulo de Convolução

### Integrantes
- Matheus Henrique Perotti Moreira (22150181)  
- Nairel Flores Prandini (23200449)  
- Felipe Tomczak Farkuh (23200453)  
- Vitor Pedrosa Brito dos Santos (23203910)  
- Igor Machado (25102201)  
- Bernard Silveira Damascena Lima Silva (25102944)  
- João Gabriel Morandini Horn (25104406)  
- Enzo Bartelt (25205305)

## Descrição do Projeto

O projeto consiste no desenvolvimento de um **módulo digital de convolução** para aplicação de filtros em imagens em **escala de cinza** (grayscale) de **8 bits (0–255)**.

O sistema realiza o **cálculo da convolução** de cada pixel da imagem com um **kernel 3×3**, a fim de aplicar filtros inteiros como *sharpen* ou *sobel* e *emboss*.

A arquitetura foi dividida em **módulos reutilizáveis e parametrizáveis**, permitindo que o circuito aceite imagens de tamanhos genéricos `img_width × img_height`.  
O kernel é armazenado em uma **ROM** de 9 valores (um para cada posição da janela 3×3), cada valor com sendo um inteiro de **4 bits signed**, limitando o numero de kernels possiveis porém facilitando a normalização dos resultados.

### Funcionamento Geral

1. A imagem de entrada é armazenada em uma **ROM** (memória de pixels).  
2. O **módulo de convolução** percorre a imagem linha a linha.  
3. A cada 9 ciclos de clock, uma nova janela 3×3 é formada e o valor convoluído do pixel central é calculado.  
4. O valor resultante é **clipado** (limitado entre 0 e 255) e enviado como saída.  
5. O processo se repete até todos os pixels da imagem serem processados.

---

## Principais Componentes Desenvolvidos

### Calculadora de Endereço (`address_calculator`)

Responsável por gerar o **endereço de leitura** da ROM de pixels com base nas coordenadas **X** e **Y** como entradas.

- **Entradas:** `x`, `y`, `img_width`  
- **Saída:** `addr` (endereço linear da memória)

A fórmula usada é:
```
addr = y * img_width + x
```

Esse módulo é totalmente combinacional e atua como uma função auxiliar no datapath.

---

### Indexador de Janela (`window_indexer`)

Componente que recebe as coordenadas atuais (**X, Y**) e o índice local da janela (**0–8**) e gera uma cordenada (**X, Y**) do pixel correspondente à posição da janela 3×3.

- **Entradas:**  
  - `x`, `y` - coordenadas atuais  
  - `index` - índice 0–8 dentro da janela  

- **Saída:**  
  - `x` → coordenada X do pixel a ser lido.
  - `y` → coordenada Y do pixel a ser lido.
  - `invalid` - sinal de controle que indica operação inválida (borda da imagem)

O cálculo é feito combinacionalmente, todos os endereços possiveis são calculados porém só o relevante é selecionado a partir de um decodificador usando a entrada index.



# Bloco de Controle (BC) - Máquina de Estados

Este documento descreve a lógica de controle implementada na entidade `bc` (Block Controller). Este bloco é responsável por orquestrar o fluxo de dados para uma operação de convolução de imagens, gerenciando o endereçamento de memória, a janela deslizante (kernel) e os acumuladores.

## Visão Geral da FSM

A Máquina de Estados Finita (FSM) gerencia a iteração sobre os pixels da imagem e, para cada pixel, a iteração sobre a janela de convolução (ex: kernel 3x3).

### Fluxo de Operação
1.  **Wait:** Aguarda sinal de `enable`.
2.  **Processamento da Janela:** Para cada posição do kernel, calcula o endereço, verifica se é válido (tratamento de borda), lê a memória e acumula o resultado.
3.  **Controle de Loop:**
    * **Loop Interno (Janela):** Itera até completar o kernel (`done_window`).
    * **Loop Horizontal (Width):** Avança para o próximo pixel da linha.
    * **Loop Vertical (Height):** Ao fim da linha, avança para a próxima e reseta a coluna.

## Tabela de Estados e Sinais de Saída

A tabela abaixo detalha o comportamento de cada estado.
**Nota:** Apenas os sinais listados na coluna "Sinais Ativos" são setados para `'1'` (High). Todos os outros sinais de saída permanecem em `'0'` (Low) para evitar *latches* indesejados.

| Estado | Descrição | Sinais Ativos (`'1'`) |
| :--- | :--- | :--- |
| **S_IDLE** | Estado de espera. Reseta contadores e flags de conclusão. | `R_CW`, `R_CH`, `R_CI`, `R_ACC`, `R_ADDR`, `R_MEM`, `done` |
| **S_CALC_ADDR** | Habilita o cálculo do endereço de memória do pixel atual da janela. | `E_ADDR` |
| **S_READ_MEM** | Realiza a leitura da memória (se o endereço for válido). | `E_MEM`, `read_mem` |
| **S_CALC_ACC** | Habilita a multiplicação/acumulação e incrementa índice do kernel. | `E_CI`, `E_ACC` |
| **S_INVALID** | Trata bordas/pixels inválidos. Reseta endereço e avança índice do kernel. | `R_ADDR`, `E_CI` |
| **S_WINDOW_DONE** | Indica que o cálculo da janela (convolução de 1 pixel) terminou. | `sample_ready` |
| **S_INC_WIDTH** | Avança para a próxima coluna da imagem. Reseta acumulador e índice do kernel. | `E_CW`, `R_CI`, `R_ACC` |
| **S_INC_HEIGHT** | Avança para a próxima linha da imagem. Reseta coluna, acumulador e índice. | `E_CH`, `R_CW`, `R_CI`, `R_ACC` |

### Legenda dos Prefixos de Sinais
* **E_... (Enable):** Habilita escrita, incremento ou leitura (ex: `E_ACC` habilita o registrador acumulador).
* **R_... (Reset):** Reinicia um contador ou registrador específico (ex: `R_CW` zera o contador de largura/coluna).
* **read_mem:** Sinal direto para a interface de memória.
* **done / sample_ready:** Flags de status para o sistema externo.


# Testbench: Módulo de Convolução (`tb_convolution_module`)

Este ambiente de teste valida a integridade funcional do `convolution_module`. Ele simula o processamento completo de uma imagem de 3x3 pixels, atuando como o sistema externo (memória e controlador mestre) e realizando a verificação automática dos resultados (self-checking).

## Cenários de Teste

O testbench do TOP-LEVEL foi configurado para um cenário pequeno para facilitar a visualização da forma de onda e depuração.
As saidas corretas foram pré-calculadas a mão.

| Parâmetro | Configuração | Descrição |
| :--- | :--- | :--- |
| **Dimensões** | 3 x 3 pixels | Imagem mínima para testar bordas e centro. |
| **Clock (`T_CLK`)** | 5 ns | Frequência de operação simulada de 200 MHz. |
| **Kernel** | `kernel_edge_detection` | Filtro de detecção de bordas (definido no pacote). |
| **Entradas (`RAM_DATA`)** | Gradiente 10 a 90 | Valores crescentes para facilitar rastreio (10, 20... 90). |
| **Verificação** | Automática | Compara a saída com `EXPECTED_DATA` ciclo a ciclo. |

## Estrutura e Processos

A arquitetura do testbench é dividida em processos concorrentes que emulam o hardware periférico:

* **`UUT` (Unit Under Test):** Instância do design principal com *generics* mapeados para 3x3.
* **`p_clk` (Clock Gen):** Gera o sinal de clock perpétuo com período de 5ns.
* **`p_mem` (Emulador de RAM):**
    * Atua como uma memória assíncrona de leitura.
    * Lê o sinal `addr` do UUT e disponibiliza o dado no `sample_in` imediatamente.
    * Trata endereços fora do range (padding com 0).
* **`p_stim` (Estímulos):**
    * Gerencia a sequência de Reset.
    * Gera o pulso de `enable` para iniciar a máquina.
    * Encerra a simulação ao receber o sinal `done`.
* **`p_monitor` (Verificador):**
    * Sincronizado com o clock.
    * Monitora a flag `sample_ready`.
    * Compara o valor de `sample_out` com o array `EXPECTED_DATA`.
    * **Report:** Imprime mensagens no console apenas se houver divergência (erro).

## Como Interpretar a Saída

1.  **Sucesso:** Se a simulação rodar e exibir apenas "Fim da Simulacao", o design está correto.
2.  **Falha:** Mensagens no formato `Pixel de Saida #X | Valor: Y, esperado: Z` indicarão exatamente onde o cálculo diferiu do modelo esperado.


#### Source

O código-fonte do projeto está disponível em https://github.com/nairel-git/convolution_module