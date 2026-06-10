# Watusi Clones

Repositório com 30 clones do WhatsApp Business com Watusi 3 para instalação via ESign, AltStore ou outras lojas iOS.

## 🔗 URL do Repositório (ESign/AltStore)

```
https://raw.githubusercontent.com/adfastltda/watusi/master/apps.json
```

## 📥 Como Usar

### ESign
1. Abra o ESign
2. Vá em "Sources" ou "Repositórios"
3. Adicione a URL: `https://raw.githubusercontent.com/adfastltda/watusi/v26.16.74/apps.json`
4. Os apps aparecerão na lista para instalação

### AltStore
1. Abra o AltStore
2. Vá em "Browse" → "Sources"
3. Adicione a URL do repositório
4. Instale os apps diretamente

### Download Direto
Acesse a [página de Releases](https://github.com/adfastltda/watusi/releases/tag/v26.16.74) para baixar os arquivos IPA individualmente.

## ⚙️ Estrutura do Projeto

```
watusi/
├── apps.json              # Manifesto no formato AltStore/ESign
├── README.md              # Este arquivo
├── .gitignore             # Arquivos ignorados pelo git
├── clones/                # 📦 30 arquivos IPA gerados
│   ├── WA_01.ipa
│   ├── WA_02.ipa
│   ├── ...
│   └── WA_30.ipa
├── scripts/               # 🛠️ Scripts de automação
│   └── clone_ipa.sh       # Script para gerar clones
├── assets/                # 🎨 Recursos visuais
│   └── icon.png           # Ícone do app
├── docs/                  # 📚 Documentação
│   └── RELEASE_INSTRUCTIONS.md
└── source/                # 📥 Arquivos fonte
    └── original.ipa       # IPA original usado como base
```

## 📝 Notas

- Cada clone tem um Bundle ID único para permitir instalação lado a lado
- Todos incluem Watusi 3 (versão 1.3.10)
- Baseado no WhatsApp Business versão 26.16.74
- Tamanho de cada IPA: ~140MB

## ⚠️ Aviso

Estes são mods não oficiais do WhatsApp. Use por sua conta e risco.
