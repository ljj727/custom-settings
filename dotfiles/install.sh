#!/bin/bash

set -e

DOTFILES_DIR="$HOME/dotfiles"

if [ ! -d "$DOTFILES_DIR" ]; then
    echo "❌ $DOTFILES_DIR 디렉토리가 없습니다!"
    exit 1
fi

MODE="${1:-mac}"

echo "🚀 Dotfiles 설치 시작... (모드: $MODE)"

# stow 설치 확인
if ! command -v stow &> /dev/null; then
    echo "📦 stow 설치 중..."
    if [[ "$MODE" == "mac" ]]; then
        brew install stow
    else
        sudo apt update && sudo apt install -y stow
    fi
fi

cd "$DOTFILES_DIR"

# 기존 파일 백업 함수
backup_if_exists() {
    if [ -f "$1" ] || [ -d "$1" ]; then
        BACKUP="$1.backup.$(date +%Y%m%d_%H%M%S)"
        echo "📦 $1 → $BACKUP"
        mv "$1" "$BACKUP"
    fi
}

echo "🔄 기존 설정 백업 중..."
backup_if_exists "$HOME/.config/nvim"
backup_if_exists "$HOME/.tmux.conf"
backup_if_exists "$HOME/.zshrc"
backup_if_exists "$HOME/.gitconfig"
backup_if_exists "$HOME/.fzf.zsh"

# stow 적용
echo "🔗 심볼릭 링크 생성 중..."
stow */  # 모든 패키지 한번에 적용

echo ""
echo "✅ Dotfiles 설치 완료!"
echo ""

# 환경별 추가 설정 안내
if [[ "$MODE" == "mac" ]]; then
    echo "📝 Mac 환경 - 다음 도구들을 설치하세요:"
    echo "  brew install neovim tmux fd fzf ripgrep node"
    echo "  curl -LsSf https://astral.sh/uv/install.sh | sh"
else
    echo "📝 Linux 환경 - 다음 명령어를 실행하세요:"
    echo ""
    echo "# Neovim 최신 버전"
    echo "curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage"
    echo "chmod u+x nvim.appimage && sudo mv nvim.appimage /usr/local/bin/nvim"
    echo ""
    echo "# 기타 도구"
    echo "sudo apt install -y tmux fd-find ripgrep nodejs npm"
    echo "curl -LsSf https://astral.sh/uv/install.sh | sh"
    echo ""
    echo "# fzf"
    echo "git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf"
    echo "~/.fzf/install"
    echo ""
    echo "# fd 심볼릭 링크 (Ubuntu)"
    echo "mkdir -p ~/.local/bin"
    echo "ln -s \$(which fdfind) ~/.local/bin/fd"
fi

echo ""
echo "⚙️  추가 설정 필요:"
echo "1. git 사용자 정보 설정:"
echo "   git config --global user.name \"Your Name\""
echo "   git config --global user.email \"your@email.com\""
echo ""
echo "2. ~/.zshrc 하단에 머신별 PATH 추가:"
echo "   export PATH=\"\$HOME/.local/bin:\$PATH\""
echo "   export PATH=\"\$HOME/.cargo/bin:\$PATH\""
echo ""
echo "🎉 완료! 터미널을 재시작하거나 'source ~/.zshrc'를 실행하세요."
