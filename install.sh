#!/bin/bash
# Light Node Version Manager - Script de Instalação
# Uso: curl -fsSL https://raw.githubusercontent.com/GabrielGCardoso/light-nvm/main/install.sh | bash

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo ""
echo -e "${CYAN}╔════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                                                ║${NC}"
echo -e "${CYAN}║     Light Node Version Manager (lnvm)         ║${NC}"
echo -e "${CYAN}║          Script de Instalação                  ║${NC}"
echo -e "${CYAN}║                                                ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════╝${NC}"
echo ""

# Detecta shell
detect_shell() {
    if [ -n "$ZSH_VERSION" ]; then
        echo "zsh"
    elif [ -n "$BASH_VERSION" ]; then
        echo "bash"
    else
        echo "unknown"
    fi
}

CURRENT_SHELL=$(detect_shell)
SHELL_NAME=$(basename "$SHELL")

echo -e "${BLUE}[1/6]${NC} ${YELLOW}Detectando ambiente...${NC}"
echo "   ✓ Sistema operacional: $(uname -s)"
echo "   ✓ Arquitetura: $(uname -m)"
echo "   ✓ Shell detectado: $SHELL_NAME"
echo ""

# Define diretório de instalação
INSTALL_DIR="$HOME/.lnvm"
LNVM_SCRIPT="$INSTALL_DIR/lnvm.sh"

echo -e "${BLUE}[2/6]${NC} ${YELLOW}Criando diretório de instalação...${NC}"
if [ -d "$INSTALL_DIR" ]; then
    echo "   ⚠️  Diretório $INSTALL_DIR já existe"
    read -p "   Deseja sobrescrever? (s/N): " -n 1 -r < /dev/tty
    echo
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        echo -e "${RED}   ✗ Instalação cancelada${NC}"
        exit 1
    fi
    rm -rf "$INSTALL_DIR"
fi
mkdir -p "$INSTALL_DIR"
echo -e "   ${GREEN}✓${NC} Diretório criado: $INSTALL_DIR"
echo ""

echo -e "${BLUE}[3/6]${NC} ${YELLOW}Baixando lnvm.sh...${NC}"
# Se estiver rodando localmente (para desenvolvimento), copia o arquivo
if [ -f "$(dirname "$0")/lnvm.sh" ]; then
    echo "   ℹ️  Instalação local detectada"
    cp "$(dirname "$0")/lnvm.sh" "$LNVM_SCRIPT"
else
    # Baixa do repositório
    if curl -fsSL https://raw.githubusercontent.com/GabrielGCardoso/light-nvm/main/lnvm.sh -o "$LNVM_SCRIPT"; then
        echo "   ✓ lnvm.sh baixado do GitHub"
    else
        echo -e "   ${RED}✗ Erro ao baixar lnvm.sh${NC}"
        echo "   💡 Verifique sua conexão ou baixe manualmente de:"
        echo "      https://github.com/GabrielGCardoso/light-nvm"
        exit 1
    fi
fi
echo -e "   ${GREEN}✓${NC} lnvm.sh instalado"
echo ""

echo -e "${BLUE}[4/6]${NC} ${YELLOW}Criando diretório para versões do Node...${NC}"
NODE_VERSIONS_DIR="$INSTALL_DIR/versions"
mkdir -p "$NODE_VERSIONS_DIR"
echo -e "   ${GREEN}✓${NC} Diretório criado: $NODE_VERSIONS_DIR"
echo ""

echo -e "${BLUE}[5/6]${NC} ${YELLOW}Configurando shell...${NC}"

# Detecta arquivo de configuração do shell
if [ "$SHELL_NAME" = "zsh" ] || [ -f "$HOME/.zshrc" ]; then
    SHELL_RC="$HOME/.zshrc"
elif [ "$SHELL_NAME" = "bash" ]; then
    if [ -f "$HOME/.bashrc" ]; then
        SHELL_RC="$HOME/.bashrc"
    else
        SHELL_RC="$HOME/.bash_profile"
    fi
else
    SHELL_RC="$HOME/.profile"
fi

# Verifica se já está configurado
if grep -q "source.*lnvm.sh" "$SHELL_RC" 2>/dev/null; then
    echo "   ℹ️  lnvm já está configurado em $SHELL_RC"
else
    echo "" >> "$SHELL_RC"
    echo "# Light Node Version Manager" >> "$SHELL_RC"
    echo "source $LNVM_SCRIPT" >> "$SHELL_RC"
    echo -e "   ${GREEN}✓${NC} Adicionado ao $SHELL_RC"
fi
echo ""

echo -e "${BLUE}[6/6]${NC} ${YELLOW}Ativando lnvm no shell atual...${NC}"
source "$LNVM_SCRIPT"
echo -e "   ${GREEN}✓${NC} lnvm carregado"
echo ""

echo -e "${GREEN}╔════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                ║${NC}"
echo -e "${GREEN}║          ✓ Instalação concluída!              ║${NC}"
echo -e "${GREEN}║                                                ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}"
echo ""

# Pergunta se quer instalar uma versão do Node
echo -e "${CYAN}Deseja instalar uma versão do Node.js agora?${NC}"
echo ""
echo "Versões LTS recomendadas:"
echo "  1) v20.11.0 (Iron - LTS até abril 2026)"
echo "  2) v18.19.0 (Hydrogen - LTS até abril 2025)"
echo "  3) Instalar outra versão"
echo "  4) Pular (instalar depois)"
echo ""
read -p "Escolha uma opção (1-4): " -n 1 -r CHOICE < /dev/tty
echo ""
echo ""

case $CHOICE in
    1)
        VERSION="v20.11.0"
        ;;
    2)
        VERSION="v18.19.0"
        ;;
    3)
        read -p "Digite a versão (ex: v20.11.0): " VERSION < /dev/tty
        ;;
    *)
        echo -e "${CYAN}Você pode instalar uma versão depois com:${NC}"
        echo -e "  ${YELLOW}lnvm install v20.11.0${NC}"
        echo ""
        echo -e "${CYAN}Comandos disponíveis:${NC}"
        echo -e "  ${YELLOW}lnvm install <version>${NC}  - Instalar uma versão do Node"
        echo -e "  ${YELLOW}lnvm list${NC}               - Listar versões instaladas"
        echo -e "  ${YELLOW}lnvm global <version>${NC}   - Definir versão global"
        echo -e "  ${YELLOW}lnvm use <version>${NC}      - Usar versão específica"
        echo ""
        echo -e "${GREEN}✨ Reabra o terminal ou execute: source $SHELL_RC${NC}"
        exit 0
        ;;
esac

if [ -n "$VERSION" ]; then
    echo -e "${CYAN}Instalando Node.js $VERSION...${NC}"
    echo ""
    lnvm install "$VERSION"
    
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${CYAN}Definir $VERSION como versão global?${NC}"
        read -p "(S/n): " -n 1 -r SET_GLOBAL < /dev/tty
        echo ""
        
        if [[ ! $SET_GLOBAL =~ ^[Nn]$ ]]; then
            lnvm global "$VERSION"
            echo ""
            echo -e "${GREEN}✓ Node.js $VERSION configurado como versão global${NC}"
            echo ""
            echo -e "${CYAN}Verificando instalação:${NC}"
            node --version
            npm --version
        fi
    fi
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                ║${NC}"
echo -e "${GREEN}║      🎉 Tudo pronto! Aproveite o lnvm!        ║${NC}"
echo -e "${GREEN}║                                                ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}📚 Comandos úteis:${NC}"
echo -e "  ${YELLOW}lnvm${NC}                     - Ver ajuda completa"
echo -e "  ${YELLOW}lnvm install v20.11.0${NC}    - Instalar uma versão"
echo -e "  ${YELLOW}lnvm list${NC}                - Listar versões"
echo -e "  ${YELLOW}lnvm global v20.11.0${NC}     - Definir versão global"
echo ""
echo -e "${CYAN}💡 Dica:${NC} Crie um arquivo ${YELLOW}.nvmrc${NC} ou ${YELLOW}.node-version${NC} nos seus projetos"
echo -e "   para trocar de versão automaticamente!"
echo ""
echo -e "${GREEN}✨ Reabra o terminal ou execute: ${YELLOW}source $SHELL_RC${NC}"
echo ""

