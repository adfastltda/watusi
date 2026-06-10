#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Gera o apps.json baseado nos arquivos IPA presentes em clones/
VERSION_DESCRIPTION="WhatsApp Business clone com Watusi 3 (1.3.10)"
CLONES_DIR="$REPO_ROOT/clones"
OUTPUT="$REPO_ROOT/apps.json"
VERSION=$(cat "$REPO_ROOT/VERSION")
RELEASE_TAG="v$VERSION"
BASE_URL="https://github.com/adfastltda/watusi/releases/download/${RELEASE_TAG}"
ICON_URL="https://raw.githubusercontent.com/adfastltda/watusi/main/assets/icon.png"
SOURCE_URL="https://raw.githubusercontent.com/adfastltda/watusi/main/apps.json"
VERSION_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Coletar e ordenar IPAs
shopt -s nullglob
IPAS=("$CLONES_DIR"/WA_*.ipa)
shopt -u nullglob

if ((${#IPAS[@]} > 1)); then
    mapfile -t IPAS < <(printf '%s\n' "${IPAS[@]}" | sort)
fi

if [ ${#IPAS[@]} -eq 0 ]; then
    echo "Nenhum IPA encontrado em $CLONES_DIR"
    exit 1
fi

echo "Encontrados ${#IPAS[@]} IPAs em $CLONES_DIR"

{
    cat <<EOF
{
  "name": "Watusi Clones",
  "identifier": "net.adfast.watusi.clones",
  "sourceURL": "${SOURCE_URL}",
  "apps": [
EOF

    TOTAL=${#IPAS[@]}
    for idx in "${!IPAS[@]}"; do
        IPA="${IPAS[$idx]}"
        FILENAME=$(basename "$IPA")
        # Extrai número do nome WA_01.ipa -> 01
        NUM="${FILENAME#WA_}"
        NUM="${NUM%.ipa}"
        # Remove zeros à esquerda para o bundle ID
        NUM_INT=$((10#$NUM))
        BUNDLE_ID="net.whatsapp.WhatsAppSMB${NUM_INT}"
        NAME="WA ${NUM}"
        SIZE=$(stat -c%s "$IPA" 2>/dev/null || echo 145752064)

        COMMA=","
        if [ $((idx + 1)) -eq $TOTAL ]; then
            COMMA=""
        fi

        cat <<EOF
    {
      "name": "${NAME}",
      "subtitle": "WhatsApp Business ${NUM}",
      "bundleIdentifier": "${BUNDLE_ID}",
      "developerName": "Adfast LTDA",
      "version": "${VERSION}",
      "versionDate": "${VERSION_DATE}",
      "versionDescription": "${VERSION_DESCRIPTION}",
      "downloadURL": "${BASE_URL}/${FILENAME}",
      "localizedDescription": "${VERSION_DESCRIPTION}",
      "iconURL": "${ICON_URL}",
      "tintColor": "25D366",
      "size": ${SIZE}
    }${COMMA}
EOF
    done

    cat <<EOF
  ]
}
EOF
} > "$OUTPUT"

echo "apps.json gerado com ${TOTAL} apps em: $OUTPUT"
