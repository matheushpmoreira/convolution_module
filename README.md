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

## Máquina de estados

O processo começa no estado Idle. O próximo estado é obrigatoriamente o começo do processo de convolução, entrando no primeiro de três estados do looping que realiza a operação. O primeiro estado irá calcular o endereço a ser lido da memória. Caso seja um endereço válido, no próximo estado será feita a leitura da memória, e após isso, no próximo estado, será feita a multiplicação e soma no acumulador. Caso o endereço seja inválido (em casos onde o índice atual é a borda da imagem), o estado de leitura da memória será pulado, e o próximo estado será um outro estado de soma que emite um sinal para somar zero ao acumulador. Fora do looping há estados para o incremento do valor de índice, tanto de linha quanto de coluna.

#### Source

O código-fonte do projeto está disponível em https://github.com/nairel-git/convolution_module