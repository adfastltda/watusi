#!/bin/bash

# Script para clonar IPA do WhatsApp com diferentes nomes e bundle IDs
# Uso: ./clone_ipa.sh

set -e
QNT=13
THREADS=13
IPA_ORIGINAL=$(ls /root/watusi/source/*.ipa | tail -1)
OUTPUT_DIR="/root/watusi/clones"
TEMP_DIR="/tmp/ipa_clone_work"

# Criar diretórios
mkdir -p "$OUTPUT_DIR"
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"

echo "=== Extraindo IPA original ==="
cd "$TEMP_DIR"
unzip -q "$IPA_ORIGINAL"

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
    local NUM=$(printf "%02d" $i)
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
    cp -r "$TEMP_DIR/Payload" "$CLONE_DIR/"

    # Modificar Info.plist
    local PLIST_PATH="$CLONE_DIR/Payload/WhatsApp.app/Info.plist"
    modificar_plist "$PLIST_PATH" "$BUNDLE_ID" "$CLONE_NAME"

    # Empacotar novo IPA
    cd "$CLONE_DIR"
    zip -qr "$OUTPUT_IPA" Payload

    echo "   Criado: $OUTPUT_IPA"
}

# Criar clones com paralelização
for i in $(seq 1 $QNT); do
    criar_clone $i &

    # Controlar número de threads
    if (( i % THREADS == 0 )); then
        wait
    fi
done

# Aguardar últimos jobs
wait

# Limpar arquivos temporários
rm -rf "$TEMP_DIR"

echo ""
echo "=== Concluído! $QNT clones criados em: $OUTPUT_DIR ==="
ls -lh "$OUTPUT_DIR"
