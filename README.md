# Light Node Version Manager (lnvm)

> Gerenciador minimalista de versões do Node.js em bash puro - feito para ser **simples, portável e fácil de instalar**

## 🎯 Por que este projeto existe?

Este não é "mais um gerenciador de Node.js". O **lnvm** foi criado para resolver um problema específico:

- ✅ **Ambientes corporativos restritos** onde você não pode instalar ferramentas complexas
- ✅ **MinGW/Git Bash no Windows** onde nvm/fnm podem não funcionar bem
- ✅ **Instalação rápida** - literalmente copiar e colar dois arquivos
- ✅ **Sem dependências externas** - apenas bash puro
- ✅ **Menos features, mais portabilidade** - faz o essencial muito bem

Se você precisa de algo que "simplesmente funcione" em ambientes restritivos (Linux, macOS, Windows MinGW, WSL, servidores), este essa pode ser uma boa opção.

---

## 📦 Instalação

### Opção 1: Script interativo (recomendado)

**Instalação local:**
```bash
bash install.sh
```

**Instalação remota:**
```bash
curl -fsSL https://raw.githubusercontent.com/GabrielGCardoso/light-nvm/main/install.sh | bash
```

O instalador vai:
1. Criar `~/.lnvm/` e configurar tudo
2. Adicionar ao seu `.bashrc` ou `.zshrc`
3. Perguntar se quer instalar uma versão LTS
4. Pronto para usar! ✨

### Opção 2: Copiar e colar (para ambientes restritos)

Perfeito para quando você não tem permissões ou quer controle total:

```bash
# 1. Crie a estrutura
mkdir -p ~/.lnvm/versions

# 2. Copie o lnvm.sh para ~/.lnvm/
cp lnvm.sh ~/.lnvm/

# 3. Adicione ao seu shell config
echo 'source ~/.lnvm/lnvm.sh' >> ~/.bashrc  # ou ~/.zshrc

# 4. Recarregue
source ~/.bashrc

# 5. Baixe manualmente uma versão do Node (exemplo)
cd ~/.lnvm/versions
wget https://nodejs.org/dist/v20.11.0/node-v20.11.0-linux-x64.tar.xz
tar -xf node-v20.11.0-linux-x64.tar.xz
mv node-v20.11.0-linux-x64 nodev20.11.0
rm node-v20.11.0-linux-x64.tar.xz

# 6. Configure como global
lnvm global v20.11.0
```

### Instalação no Windows (MinGW/Git Bash)

```bash
# Mesmo processo! Use caminhos Windows se necessário:
mkdir -p ~/lnvm/versions
cp lnvm.sh ~/lnvm/
echo 'source ~/lnvm/lnvm.sh' >> ~/.bashrc
source ~/.bashrc

# Baixe versão Windows do Node
cd ~/lnvm/versions
curl -O https://nodejs.org/dist/v20.11.0/node-v20.11.0-win-x64.zip
unzip node-v20.11.0-win-x64.zip
mv node-v20.11.0-win-x64 nodev20.11.0
lnvm global v20.11.0
```

---

## 🚀 Uso

```bash
# Instalar uma versão (baixa automaticamente)
lnvm install v20.11.0

# Definir versão global padrão
lnvm global v20.11.0

# Usar versão específica neste terminal
lnvm use v18.17.0

# Listar versões instaladas
lnvm list

# Ver versão atual
lnvm current

# Ajuda
lnvm
```

### Auto-detecção de versão por projeto

Crie um desses arquivos no seu projeto:

**`.nvmrc`** (compatível com nvm):
```
v18.17.0
```

**`.node-version`**:
```
v20.11.0
```

**`package.json`**:
```json
{
  "engines": {
    "node": "v18.17.0"
  }
}
```

Quando você entrar no diretório, o lnvm troca automaticamente:

```bash
cd ~/meu-projeto
# [lnvm] Usando Node v18.17.0

cd ~
# [lnvm] Usando Node v20.11.0 (global)
```

---

## 🏗️ Estrutura

Tudo fica organizado em um único diretório:

```
~/.lnvm/
├── lnvm.sh           # Script principal (255 linhas)
├── global            # Arquivo com versão global atual
└── versions/         # Versões instaladas
    ├── nodev20.11.0/
    │   └── bin/
    │       ├── node
    │       ├── npm
    │       └── npx
    └── nodev18.17.0/
        └── bin/
```

Para desinstalar, basta deletar:
```bash
rm -rf ~/.lnvm
# Remove do .bashrc/.zshrc manualmente
```

---

## 💡 Como funciona

### Troca automática de versão

O lnvm detecta mudanças de diretório usando hooks nativos do shell:

- **Zsh**: usa `chpwd_functions` (hook nativo)
- **Bash**: usa `PROMPT_COMMAND` (verifica se `$PWD` mudou)
- **Outros**: fallback com override do comando `cd`

**Importante**: Comandos como `ls`, `grep`, etc. **não são afetados**. O hook só executa quando você realmente muda de diretório.

### Versão global

A versão global é salva em `~/.lnvm/global`:
- Persiste entre terminais
- Cada novo terminal/sessão lê automaticamente
- Terminais já abertos mantêm sua versão até recarregar

### Isolamento

Cada terminal mantém sua própria versão independente via `$PATH`:
```bash
# Terminal 1
lnvm use v20.11.0

# Terminal 2 (não é afetado)
node --version  # ainda v18.17.0
```

---

## 🌍 Compatibilidade

### Shells suportados:
- ✅ Bash 3.2+
- ✅ Zsh 5.0+
- ✅ MinGW/Git Bash (Windows)
- ✅ WSL (Windows Subsystem for Linux)

### Sistemas operacionais:
- ✅ Linux (qualquer distro)
- ✅ macOS
- ✅ Windows (via MinGW, Git Bash, WSL)
- ✅ Servidores/containers

### Por que funciona em ambientes corporativos?

1. **Não precisa de root/admin** - instala em `~/.lnvm`
2. **Sem compilação** - bash puro, sem build step
3. **Sem dependências** - só precisa de `bash`, `wget`/`curl`, `tar`
4. **Funciona offline** - baixe versões manualmente se necessário
5. **Fácil de auditar** - apenas um arquivo de 255 linhas

---

## ❓ FAQ

### Por que não usar nvm?

- nvm pode não funcionar bem dependendo dos bloqueios impostos para baixar versões
- nvm é mais complexo mais trabalhoso para instalar manualmente
- lnvm é mais simples e portável
- lnvm você pode baixar facilmente as versões sem usar o comando de install

### Por que não usar fnm?

- fnm precisa ser compilado (Rust/Cargo)
- Em ambientes corporativos você pode não conseguir instalar Rust
- lnvm é apenas copiar um arquivo bash


### Como desinstalar uma versão?

```bash
rm -rf ~/.lnvm/versions/nodev18.17.0
```

### Funciona com package managers como pnpm?

Sim! Instale normalmente:

```bash
npm install -g pnpm
# pnpm fica em ~/.lnvm/versions/nodev20.11.0/bin/pnpm
```

---

## 🔧 Customização

Você pode mudar o diretório padrão definindo `LNVM_DIR` antes de carregar:

```bash
# No .bashrc/.zshrc, ANTES do source
export LNVM_DIR="$HOME/meu-lnvm-customizado"
source ~/.lnvm/lnvm.sh
```

As versões ficarão em `$LNVM_DIR/versions/`.

---

## 🐛 Troubleshooting

### Versão não está trocando

```bash
# Verifique se o lnvm está carregado
type lnvm
# Deve mostrar: lnvm is a shell function

# Recarregue o script
source ~/.lnvm/lnvm.sh
```

### Comando não encontrado após instalação

```bash
# Verifique se está no PATH
echo $PATH | grep lnvm
# Deve aparecer algo como: /home/user/.lnvm/versions/nodev20.11.0/bin

# Force reload
lnvm use v20.11.0
```

### No MinGW: wget não encontrado

Use `curl` em vez de `wget`:

```bash
# No lnvm.sh, a função _lnvm_install tenta wget primeiro
# Se não funcionar, baixe manualmente com curl:
cd ~/.lnvm/versions
curl -O https://nodejs.org/dist/v20.11.0/node-v20.11.0-win-x64.zip
```

### Erro ao descompactar no Windows

Use as versões `.zip` em vez de `.tar.xz`:

```bash
# Windows
curl -O https://nodejs.org/dist/v20.11.0/node-v20.11.0-win-x64.zip
unzip node-v20.11.0-win-x64.zip
```

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Este projeto prioriza:

1. **Simplicidade** sobre features
2. **Portabilidade** sobre otimização
3. **Clareza** sobre cleverness

Mantenha o código legível e compatível com bash 3.2+.

---

## 📄 Licença

MIT License - use como quiser, em qualquer ambiente!

---

## 🎯 Filosofia do projeto

> "Faça uma coisa. Faça bem. Seja portável."

Este projeto não tenta competir com nvm ou fnm em features. O objetivo é ser:

- **Minimalista**: menos é mais
- **Portável**: funciona em qualquer lugar com bash
- **Prático**: resolve problemas reais de ambientes corporativos
- **Simples**: você consegue ler e entender todo o código em 10 minutos

Se você precisa de algo "que simplesmente funciona" sem complicação, você está no lugar certo.

---

<div align="center">
  <sub>Feito com ❤️ em bash puro - 255 linhas, zero dependências</sub>
</div>
