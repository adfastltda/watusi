#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Create GitHub release with all IPA files
shopt -s nullglob
IPAS=("$REPO_ROOT"/clones/*.ipa)
shopt -u nullglob

if ((${#IPAS[@]} == 0)); then
    echo "Nenhum IPA encontrado em $REPO_ROOT/clones"
    exit 1
fi

VERSION=$(cat "$REPO_ROOT/VERSION")
gh release create v"$VERSION" "${IPAS[@]}"
