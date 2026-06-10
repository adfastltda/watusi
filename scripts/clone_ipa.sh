#!/bin/bash

# Script para clonar IPA do WhatsApp com diferentes nomes e bundle IDs
# Uso: ./clone_ipa.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SOURCE_DIR="$REPO_ROOT/source"
OUTPUT_DIR="$REPO_ROOT/clones"
TEMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/watusi-clone-XXXXXX")"
QNT=50
THREADS=10

trap 'rm -rf "$TEMP_DIR"' EXIT

shopt -s nullglob
SOURCE_IPAS=("$SOURCE_DIR"/*.ipa)
shopt -u nullglob

if (( ${#SOURCE_IPAS[@]} == 0 )); then
    echo "Nenhum arquivo .ipa encontrado em $SOURCE_DIR"
    echo "Coloque o IPA base em $SOURCE_DIR e tente novamente."
    exit 1
fi

IPA_ORIGINAL="${SOURCE_IPAS[0]}"

# Criar diretórios
mkdir -p "$OUTPUT_DIR"
find "$OUTPUT_DIR" -mindepth 1 -maxdepth 1 -exec rm -rf {} +

echo "=== Extraindo IPA original ==="
unzip -q "$IPA_ORIGINAL" -d "$TEMP_DIR"

# Função para modificar Info.plist
modificar_plist() {
    local plist_path="$1"
    local bundle_id="$2"
    local display_name="$3"
    
    # Modificar CFBundleIdentifier
    sed -i "s/<string>net.whatsapp.WhatsAppSMB<\/string>/<string>$bundle_id<\/string>/g" "$plist_path"
    
    # Modificar CFBundleName (nome exibido)
    sed -i "s/<string>WhatsApp Business<\/string>/<string>$display_name<\/string>/g" "$plist_path"
    
    # Modificar CFBundleDisplayName se existir
    if grep -q "CFBundleDisplayName" "$plist_path"; then
        sed -i "/CFBundleDisplayName/{n;s/<string>[^<]*<\/string>/<string>$display_name<\/string>/;}" "$plist_path"
    fi
}


# Função para criar um clone
criar_clone() {
    local i=$1
    local NUM
    NUM=$(printf "%02d" "$i")
    local CLONE_NAME="WA $NUM"
    local BUNDLE_ID="net.whatsapp.WhatsAppSMB$i"
    local OUTPUT_IPA="$OUTPUT_DIR/WA_${NUM}.ipa"

    echo ""
    echo "=== Criando clone $i/$QNT: $CLONE_NAME ==="
    echo "   Bundle ID: $BUNDLE_ID"

    # Copiar arquivos extraídos para nova pasta
    local CLONE_DIR="$TEMP_DIR/clone_$i"
    rm -rf "$CLONE_DIR"
    mkdir -p "$CLONE_DIR"
    cp -al "$TEMP_DIR/Payload" "$CLONE_DIR/"

    # Modificar Info.plist
    local PLIST_PATH="$CLONE_DIR/Payload/WhatsApp.app/Info.plist"
    local PLIST_COPY="$PLIST_PATH.copy"
    cp "$PLIST_PATH" "$PLIST_COPY"
    mv "$PLIST_COPY" "$PLIST_PATH"
    modificar_plist "$PLIST_PATH" "$BUNDLE_ID" "$CLONE_NAME"

    # Empacotar novo IPA
    (
        cd "$CLONE_DIR"
        zip -qr "$OUTPUT_IPA" Payload
    )

    echo "   Criado: $OUTPUT_IPA"
}

declare -a PIDS=()
STATUS=0

# Criar clones com paralelização controlada
for i in $(seq 1 "$QNT"); do
    criar_clone "$i" &
    PIDS+=("$!")

    if ((${#PIDS[@]} >= THREADS)); then
        if ! wait "${PIDS[0]}"; then
            STATUS=1
        fi
        PIDS=("${PIDS[@]:1}")
    fi
done

# Aguardar últimos jobs
for pid in "${PIDS[@]}"; do
    if ! wait "$pid"; then
        STATUS=1
    fi
done

if (( STATUS != 0 )); then
    echo "Falha ao gerar um ou mais clones"
    exit "$STATUS"
fi

echo ""
echo "=== Concluído! $QNT clones criados em: $OUTPUT_DIR ==="
ls -lh "$OUTPUT_DIR"
