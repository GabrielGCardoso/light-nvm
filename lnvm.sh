# Diretório base das versões
export LNVM_DIR="${LNVM_DIR:-$HOME/.lnvm}"
export NODE_VERSIONS_DIR="$LNVM_DIR/versions"
export LNVM_GLOBAL_FILE="$LNVM_DIR/global"

# Lê a versão global do arquivo (não assume padrão se não existir)
_lnvm_load_global() {
  if [ -f "$LNVM_GLOBAL_FILE" ]; then
    cat "$LNVM_GLOBAL_FILE"
  else
    echo ""  # sem padrão - usuário deve definir com 'lnvm global'
  fi
}

export NODE_GLOBAL_VERSION=$(_lnvm_load_global)

# Função para ativar uma versão
use_node_version() {
  local version=$1
  local silent=$2  # se passar "silent", não mostra mensagens
  local node_path="$NODE_VERSIONS_DIR/node$version/bin"

  if [ -d "$node_path" ]; then
    export PATH="$node_path:$(echo "$PATH" | tr ':' '\n' | grep -v "$NODE_VERSIONS_DIR" | paste -sd ':')"
    export CURRENT_NODE_VERSION="$version"
    [ "$silent" != "silent" ] && echo "[lnvm] Usando Node $version"
    return 0
  else
    if [ "$silent" != "silent" ]; then
      echo "[lnvm] ⚠️  Node $version não encontrado em $NODE_VERSIONS_DIR"
      echo "[lnvm] Instale com: lnvm install $version"
    fi
    return 1
  fi
}

# Detecta a versão do projeto
detect_node_version() {
  local dir="$PWD"
  local version=""

  # Procura um arquivo .node-version
  if [ -f "$dir/.node-version" ]; then
    version=$(cat "$dir/.node-version")
  elif [ -f "$dir/.nvmrc" ]; then
    version=$(cat "$dir/.nvmrc")
  elif [ -f "$dir/package.json" ]; then
    version=$(grep -o '"node": *"[^"]*"' "$dir/package.json" | grep -o 'v[0-9][^"]*')
  fi

  echo "$version"
}

# Hook que roda ao mudar de diretório
auto_switch_node() {
  local version
  version=$(detect_node_version)

  if [ -n "$version" ] && [ "$version" != "$CURRENT_NODE_VERSION" ]; then
    # Tenta trocar para versão do projeto
    if use_node_version "$version" "silent"; then
      echo "[lnvm] Usando Node $version"
    else
      # Se falhar, mostra o erro
      echo "[lnvm] ⚠️  Node $version não encontrado em $NODE_VERSIONS_DIR"
      echo "[lnvm] Instale com: lnvm install $version"
    fi
  elif [ -z "$version" ] && [ -n "$NODE_GLOBAL_VERSION" ] && [ "$CURRENT_NODE_VERSION" != "$NODE_GLOBAL_VERSION" ]; then
    # Volta para versão global (silencioso se falhar)
    if use_node_version "$NODE_GLOBAL_VERSION" "silent"; then
      echo "[lnvm] Usando Node $NODE_GLOBAL_VERSION"
    fi
  fi
}

# Função para instalar uma versão do Node
_lnvm_install() {
  local version=$1
  
  if [ -z "$version" ]; then
    echo "Uso: lnvm install <version>"
    echo "Exemplo: lnvm install v20.11.0"
    echo ""
    echo "Versões LTS recomendadas:"
    echo "  - v20.11.0 (Iron - LTS até abril 2026)"
    echo "  - v18.19.0 (Hydrogen - LTS até abril 2025)"
    return 1
  fi
  
  # Normaliza a versão (adiciona 'v' se não tiver)
  if [[ ! "$version" =~ ^v ]]; then
    version="v${version}"
  fi
  
  local target_dir="$NODE_VERSIONS_DIR/node$version"
  
  if [ -d "$target_dir" ]; then
    echo "[lnvm] ✓ Node $version já está instalado"
    return 0
  fi
  
  # Detecta arquitetura
  local arch=$(uname -m)
  if [ "$arch" = "x86_64" ]; then
    arch="x64"
  elif [ "$arch" = "aarch64" ]; then
    arch="arm64"
  fi
  
  local os=$(uname -s | tr '[:upper:]' '[:lower:]')
  local platform="${os}-${arch}"
  local filename="node-${version}-${platform}.tar.xz"
  local url="https://nodejs.org/dist/${version}/${filename}"
  
  echo "[lnvm] 📦 Baixando Node.js $version para $platform..."
  echo "[lnvm] 🌐 URL: $url"
  
  local temp_dir=$(mktemp -d)
  cd "$temp_dir"
  
  if ! wget -q --show-progress "$url" 2>&1; then
    echo "[lnvm] ❌ Erro ao baixar $version"
    echo "[lnvm] Verifique se a versão existe em: https://nodejs.org/dist/"
    rm -rf "$temp_dir"
    cd - > /dev/null
    return 1
  fi
  
  echo "[lnvm] 📂 Extraindo..."
  tar -xf "$filename"
  
  mkdir -p "$NODE_VERSIONS_DIR"
  mv "node-${version}-${platform}" "$target_dir"
  
  rm -rf "$temp_dir"
  cd - > /dev/null
  
  echo "[lnvm] ✅ Node.js $version instalado com sucesso!"
  echo "[lnvm] 📍 Localização: $target_dir"
  echo ""
  echo "Para usar: lnvm use $version"
  echo "Para definir como global: lnvm global $version"
}

# Comando principal lnvm
lnvm() {
  case "$1" in
    install)
      _lnvm_install "$2"
      ;;
    
    use)
      if [ -z "$2" ]; then
        echo "Uso: lnvm use <version>"
        echo "Exemplo: lnvm use v18.17.0"
        return 1
      fi
      use_node_version "$2"
      ;;
    
    global)
      if [ -z "$2" ]; then
        echo "Versão global atual: $NODE_GLOBAL_VERSION"
        echo "Uso: lnvm global <version>"
        echo "Exemplo: lnvm global v20.11.0"
        return 1
      fi
      # Salva no arquivo
      echo "$2" > "$LNVM_GLOBAL_FILE"
      export NODE_GLOBAL_VERSION="$2"
      echo "[lnvm] Versão global definida: $2"
      # Aplica imediatamente se não estiver em um projeto
      if [ -z "$(detect_node_version)" ]; then
        use_node_version "$2"
      fi
      ;;
    
    list|ls)
      echo "Versões instaladas em $NODE_VERSIONS_DIR:"
      if [ -d "$NODE_VERSIONS_DIR" ]; then
        ls -1 "$NODE_VERSIONS_DIR" | grep "^node" | sed 's/^node/  /'
      else
        echo "  (diretório não encontrado)"
      fi
      echo ""
      echo "Versão global: $NODE_GLOBAL_VERSION"
      echo "Versão atual: ${CURRENT_NODE_VERSION:-nenhuma}"
      ;;
    
    current)
      if [ -n "$CURRENT_NODE_VERSION" ]; then
        echo "$CURRENT_NODE_VERSION"
      else
        echo "Nenhuma versão carregada"
      fi
      ;;
    
    *)
      echo "Light Node Version Manager (lnvm)"
      echo ""
      echo "Comandos:"
      echo "  lnvm install <version>  - Baixa e instala uma versão do Node"
      echo "  lnvm use <version>      - Usa uma versão específica neste shell"
      echo "  lnvm global <version>   - Define a versão global padrão"
      echo "  lnvm list               - Lista versões instaladas"
      echo "  lnvm current            - Mostra versão atual"
      echo ""
      echo "Versões são detectadas automaticamente de:"
      echo "  .node-version, .nvmrc, package.json"
      ;;
  esac
}

# Configura o hook baseado no shell
if [ -n "$ZSH_VERSION" ]; then
  # Zsh: adiciona ao array chpwd_functions (se ainda não estiver)
  autoload -U add-zsh-hook
  # Remove antes de adicionar para evitar duplicatas
  add-zsh-hook -d chpwd auto_switch_node 2>/dev/null
  add-zsh-hook chpwd auto_switch_node
elif [ -n "$BASH_VERSION" ]; then
  # Bash: verifica mudança de diretório no PROMPT_COMMAND
  _lnvm_last_dir="$PWD"
  
  _lnvm_prompt_command() {
    # Só executa se mudou de diretório
    if [ "$PWD" != "$_lnvm_last_dir" ]; then
      _lnvm_last_dir="$PWD"
      auto_switch_node
    fi
  }
  
  # Adiciona ao PROMPT_COMMAND
  if [[ ! "$PROMPT_COMMAND" =~ _lnvm_prompt_command ]]; then
    PROMPT_COMMAND="_lnvm_prompt_command${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
  fi
else
  # Fallback para shells sem hooks nativos: override do cd
  cd() {
    builtin cd "$@" || return
    auto_switch_node
  }
fi

# Inicializa na versão global (se definida)
if [ -n "$NODE_GLOBAL_VERSION" ]; then
  # Tenta carregar a versão global silenciosamente
  if ! use_node_version "$NODE_GLOBAL_VERSION" "silent"; then
    echo "[lnvm] ⚠️  Versão global $NODE_GLOBAL_VERSION não está instalada"
    echo "[lnvm] Instale com: lnvm install $NODE_GLOBAL_VERSION"
  fi
else
  echo "[lnvm] Nenhuma versão global definida. Use: lnvm global <version>"
  echo "[lnvm] Para ver versões instaladas: lnvm list"
fi