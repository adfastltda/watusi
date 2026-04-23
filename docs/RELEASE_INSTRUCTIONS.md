# 📦 Instruções para Publicar os IPAs no GitHub

Os arquivos IPA são muito grandes (~140MB cada) para serem commitados diretamente no repositório. Eles devem ser publicados como **Release Assets**.

## 🚀 Método 1: Interface Web do GitHub (Recomendado)

1. Acesse: `https://github.com/adfastltda/watusi/releases`

2. Clique em **"Create a new release"** ou **"Draft a new release"**

3. Preencha:
   - **Tag version**: `v1.0`
   - **Release title**: `Watusi Clones v1.0`
   - **Description**: 
     ```
     10 clones do WhatsApp Business com Watusi 3
     - Versão base: 26.14.73
     - Watusi: 1.3.9
     ```

4. Em **"Attach binaries"** arraste ou selecione os 10 arquivos IPA da pasta `/root/watusi/clones/`:
   - WA_01.ipa
   - WA_02.ipa
   - WA_03.ipa
   - WA_04.ipa
   - WA_05.ipa
   - WA_06.ipa
   - WA_07.ipa
   - WA_08.ipa
   - WA_09.ipa
   - WA_10.ipa

5. Clique em **"Publish release"**

## 🖥️ Método 2: GitHub CLI (gh)

Se tiver o GitHub CLI instalado:

```bash
cd /root/watusi/clones

# Criar release e fazer upload de todos os IPAs
gh release create v1.0 \
  WA_*.ipa \
  --title "Watusi Clones v1.0" \
  --notes "10 clones do WhatsApp Business com Watusi 3"
```

## 🔧 Método 3: Script com API do GitHub

### Pré-requisitos:
- Criar um **Personal Access Token** em: https://github.com/settings/tokens
- Marcar a permissão `repo` (ou `public_repo` se o repo for público)

### Script:

```bash
#!/bin/bash

TOKEN="seu_token_aqui"
REPO="adfastltda/watusi"
TAG="v1.0"
CLONES_DIR="/root/watusi/clones"

# 1. Criar o release
curl -X POST \
  -H "Authorization: token $TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/$REPO/releases \
  -d "{
    \"tag_name\": \"$TAG\",
    \"name\": \"Watusi Clones v1.0\",
    \"body\": \"10 clones do WhatsApp Business com Watusi 3\"
  }"

# 2. Obter o ID do release (você precisará extrair do JSON de resposta)
# 3. Fazer upload de cada IPA para o release
```

## ✅ Verificação

Após publicar, verifique se os links no `apps.json` estão funcionando:

```bash
# Testar um link
curl -I https://github.com/adfastltda/watusi/releases/download/v1.0/WA_01.ipa
```

Deve retornar `HTTP 200` ou `302 Found`.

## 🔗 URL Final do Repositório

Após tudo configurado, a URL para adicionar no ESign/AltStore será:

```
https://raw.githubusercontent.com/adfastltda/watusi/main/apps.json
```

## ⚠️ Importante

- **NUNCA** commite os arquivos `.ipa` diretamente no repositório
- Os IPAs devem estar em Releases para que os links do `apps.json` funcionem
- Cada IPA tem ~140MB, então o upload pode demorar alguns minutos
