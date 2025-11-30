import argparse
from PIL import Image
import os
import sys

def main():
    parser = argparse.ArgumentParser(description="Converte imagem (JPG/PNG) para Binário (.bin)")
    parser.add_argument("-i", "--input", required=True, help="Imagem de entrada")
    parser.add_argument("-o", "--output", help="Arquivo .bin de saída (opcional)")
    parser.add_argument("--w", type=int, help="Redimensionar largura para N pixels (opcional)")
    parser.add_argument("--h", type=int, help="Redimensionar altura para N pixels (opcional)")

    args = parser.parse_args()

    # 1. Carrega Imagem
    try:
        img = Image.open(args.input).convert("L") # Converte para Escala de Cinza
    except Exception as e:
        print(f"Erro ao abrir imagem: {e}")
        sys.exit(1)

    # 2. Redimensiona (Se solicitado)
    if args.w and args.h:
        print(f"Redimensionando de {img.width}x{img.height} para {args.w}x{args.h}...")
        img = img.resize((args.w, args.h))
    
    # 3. Define nome de saída se não informado
    if args.output:
        output_path = args.output
    else:
        filename = os.path.splitext(args.input)[0]
        output_path = filename + ".bin"

    # 4. Obtém bytes e salva
    pixel_bytes = img.tobytes()

    try:
        with open(output_path, "wb") as f:
            f.write(pixel_bytes)
            
        print(f"----------------------------------------")
        print(f"[SUCESSO] Gerado: {output_path}")
        print(f"Dimensões: {img.width} x {img.height}")
        print(f"Total Bytes: {len(pixel_bytes)}")
        print(f"----------------------------------------")
        
    except IOError as e:
        print(f"Erro ao salvar arquivo: {e}")

if __name__ == "__main__":
    main()