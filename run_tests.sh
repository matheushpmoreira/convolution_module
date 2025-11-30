#!/bin/bash

# ================= CONFIGURAÇÕES =================
# Flags de compatibilidade (Mesmas usadas na compilação)
FLAGS="--std=08 -fsynopsys"

# Tempo máximo de simulação para evitar loops infinitos
# Ajuste conforme o tamanho da sua imagem (ex: 10us, 1ms)
STOP_TIME="12ms"

# Diretório onde os arquivos de onda (.vcd) serão salvos
WAVE_DIR="waves"
mkdir -p $WAVE_DIR

# Contadores
PASS_COUNT=0
FAIL_COUNT=0
# =================================================

echo "=========================================="
echo "          INICIANDO BATERIA DE TESTES     "
echo "=========================================="

# Procura todos os arquivos .vhdl na pasta de testes
for file in ./src/tests/*.vhdl; do
    
    # Extrai o nome da entidade do arquivo (ex: tb_convolution_module)
    entity=$(grep -i "entity" "$file" | head -n 1 | awk '{print $2}')

    # Se não achou entidade, pula
    if [ -z "$entity" ]; then
        continue
    fi

    echo -n "Testando: $entity ... "

    # Executa a simulação
    # 2>&1 redireciona erros para a saída padrão para capturarmos no log se quiser
    # --assert-level=error faz o GHDL parar se houver um 'severity error' ou 'failure'
    ghdl -r $FLAGS "$entity" \
        --vcd="$WAVE_DIR/$entity.vcd" \
        --stop-time="$STOP_TIME" \
        --assert-level=failure

    # Verifica o código de saída do comando anterior ($?)
    if [ $? -eq 0 ]; then
        echo -e "\033[0;32m[PASS]\033[0m" # Verde
        ((PASS_COUNT++))
    else
        echo -e "\033[0;31m[FAIL]\033[0m" # Vermelho
        ((FAIL_COUNT++))
        echo "   -> Erro detectado! Verifique $WAVE_DIR/$entity.vcd"
    fi

done

echo "=========================================="
echo "RESUMO:"
echo -e "Passaram: \033[0;32m$PASS_COUNT\033[0m"
echo -e "Falharam: \033[0;31m$FAIL_COUNT\033[0m"
echo "=========================================="

if [ $FAIL_COUNT -eq 0 ]; then
    exit 0
else
    exit 1
fi