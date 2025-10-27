#!/bin/bash
# Ubuntu 서버용 완전 자동 설치 스크립트

set -e

DOTFILES_DIR="$HOME/dotfiles"

echo "🚀 Ubuntu 개발 환경 설치 시작..."

# 1. 시스템 업데이트
echo "📦 시스템 업데이트 중..."
sudo apt update
sudo apt upgrade -y

# 2. 기본 도구 설치
echo "🔧 기본 도구 설치 중..."
sudo apt install -y \
    git \
    curl \
    wget \
    build-essential \
    stow \
    tmux \
    zsh \
    fd-find \
    ripgrep \
    nodejs \
    npm

# 3. Neovim 최신 버전 설치
echo "📝 Neovim 설치 중..."
if ! command -v nvim &> /dev/null; then
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
    chmod u+x nvim.appimage
    sudo mv nvim.appimage /usr/local/bin/nvim
    echo "✅ Neovim 설치 완료"
else
    echo "✅ Neovim 이미 설치됨"
fi

# 4. fzf 설치
echo "🔍 fzf 설치 중..."
if [ ! -d "$HOME/.fzf" ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all
    echo "✅ fzf 설치 완료"
else
    echo "✅ fzf 이미 설치됨"
fi

# 5. uv (Python 패키지 관리자) 설치
echo "🐍 uv 설치 중..."
if ! command -v uv &> /dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
    echo "✅ uv 설치 완료"
else
    echo "✅ uv 이미 설치됨"
fi

# 6. fd 심볼릭 링크 생성 (Ubuntu는 fdfind로 설치됨)
echo "🔗 fd 심볼릭 링크 생성 중..."
mkdir -p "$HOME/.local/bin"
if [ ! -L "$HOME/.local/bin/fd" ]; then
    ln -s $(which fdfind) "$HOME/.local/bin/fd"
    echo "✅ fd 링크 생성 완료"
fi

# 7. zsh를 기본 쉘로 설정
echo "🐚 zsh를 기본 쉘로 설정 중..."
if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s $(which zsh)
    echo "✅ zsh를 기본 쉘로 설정 (재로그인 후 적용)"
else
    echo "✅ zsh 이미 기본 쉘로 설정됨"
fi

# 8. Dotfiles가 있으면 stow 적용
if [ -d "$DOTFILES_DIR" ]; then
    echo "🔗 Dotfiles 적용 중..."

    # 기존 파일 백업
    backup_if_exists() {
        if [ -f "$1" ] || [ -d "$1" ]; then
            BACKUP="$1.backup.$(date +%Y%m%d_%H%M%S)"
            echo "📦 $1 → $BACKUP"
            mv "$1" "$BACKUP"
        fi
    }

    backup_if_exists "$HOME/.config/nvim"
    backup_if_exists "$HOME/.tmux.conf"
    backup_if_exists "$HOME/.zshrc"
    backup_if_exists "$HOME/.gitconfig"
    backup_if_exists "$HOME/.fzf.zsh"

    cd "$DOTFILES_DIR"
    stow */
    echo "✅ Dotfiles 적용 완료"
else
    echo "⚠️  $DOTFILES_DIR 없음 - git clone 먼저 실행하세요"
fi

# 9. PATH 설정 추가 (zshrc에 없으면)
ZSHRC="$HOME/.zshrc"
if [ -f "$ZSHRC" ]; then
    if ! grep -q ".local/bin" "$ZSHRC"; then
        echo "" >> "$ZSHRC"
        echo "# === Local binaries ===" >> "$ZSHRC"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$ZSHRC"
        echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> "$ZSHRC"
        echo "✅ PATH 설정 추가"
    fi
fi

echo ""
echo "✅ 모든 설치 완료!"
echo ""
echo "📝 추가 설정:"
echo "1. git 사용자 정보 설정:"
echo "   git config --global user.name \"Your Name\""
echo "   git config --global user.email \"your@email.com\""
echo ""
echo "2. 터미널 재시작 또는 zsh 실행:"
echo "   exec zsh"
echo ""
echo "🎉 완료!"
