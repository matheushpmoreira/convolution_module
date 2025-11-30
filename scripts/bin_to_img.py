import argparse
from PIL import Image
import os
import sys

def main():
    parser = argparse.ArgumentParser(description="Converte Binário (.bin) para Imagem (PNG)")
    parser.add_argument("-i", "--input", required=True, help="Arquivo .bin de entrada")
    parser.add_argument("-o", "--output", help="Imagem de saída (opcional)")
    # Width e Height são OBRIGATÓRIOS para reconstruir binário sem header
    parser.add_argument("--w", type=int, required=True, help="Largura da imagem original")
    parser.add_argument("--h", type=int, required=True, help="Altura da imagem original")

    args = parser.parse_args()

    # 1. Define nome de saída
    if args.output:
        output_path = args.output
    else:
        # Tenta trocar a extensão .bin por .png, ou apenas adiciona .png
        if args.input.lower().endswith(".bin"):
            output_path = args.input[:-4] + ".png"
        else:
            output_path = args.input + ".png"

    # 2. Lê os dados binários
    try:
        with open(args.input, "rb") as f:
            data = f.read()
    except IOError as e:
        print(f"Erro ao ler arquivo: {e}")
        sys.exit(1)

    # 3. Valida tamanho
    expected_size = args.w * args.h
    actual_size = len(data)

    print(f"Lendo {args.input}...")
    print(f"Bytes lidos: {actual_size} | Esperado ({args.w}x{args.h}): {expected_size}")

    if actual_size < expected_size:
        print(f"ERRO: O arquivo é menor do que a resolução informada!")
        print(f"Faltam {expected_size - actual_size} bytes.")
        sys.exit(1)
    
    if actual_size > expected_size:
        print(f"AVISO: Arquivo maior que o esperado. Cortando excesso ({actual_size - expected_size} bytes).")
        data = data[:expected_size]

    # 4. Cria e Salva Imagem
    try:
        img = Image.frombytes("L", (args.w, args.h), data)
        img.save(output_path)
        print(f"[SUCESSO] Imagem reconstruída salva em: {output_path}")
    except Exception as e:
        print(f"Erro ao salvar imagem: {e}")

if __name__ == "__main__":
    main()