#!/bin/bash
# Dotfiles 초기 세팅 스크립트 (Mac에서 실행)

set -e

DOTFILES_DIR="$HOME/dotfiles"

echo "🚀 Dotfiles 저장소 생성 중..."

# 1. 기본 구조 생성
mkdir -p "$DOTFILES_DIR"/{nvim/.config/nvim,tmux,zsh,git,fzf}

# 2. 기존 설정 복사
echo "📦 기존 설정 파일 복사 중..."

# nvim
if [ -d "$HOME/.config/nvim" ]; then
    cp -r "$HOME/.config/nvim"/* "$DOTFILES_DIR/nvim/.config/nvim/"
fi

# tmux
if [ -f "$HOME/.tmux.conf" ]; then
    cp "$HOME/.tmux.conf" "$DOTFILES_DIR/tmux/.tmux.conf"
fi

# zsh (경로 관련 부분은 주석 처리해서 복사)
if [ -f "$HOME/.zshrc" ]; then
    cat "$HOME/.zshrc" | sed 's|^export PATH=|# export PATH=|g' > "$DOTFILES_DIR/zsh/.zshrc"
    echo "" >> "$DOTFILES_DIR/zsh/.zshrc"
    echo "# === Auto-detected paths (customize per machine) ===" >> "$DOTFILES_DIR/zsh/.zshrc"
    echo '# export PATH="$HOME/.local/bin:$PATH"' >> "$DOTFILES_DIR/zsh/.zshrc"
fi

# git
if [ -f "$HOME/.gitconfig" ]; then
    # 사용자 정보는 제외하고 복사
    grep -v "^\[user\]" "$HOME/.gitconfig" > "$DOTFILES_DIR/git/.gitconfig" || true
fi

# fzf
if [ -f "$HOME/.fzf.zsh" ]; then
    cp "$HOME/.fzf.zsh" "$DOTFILES_DIR/fzf/.fzf.zsh"
fi

# 3. README 생성
cat > "$DOTFILES_DIR/README.md" << 'EOF'
# My Dotfiles

개발 환경 설정을 관리하는 저장소입니다.

## 포함된 설정

- **nvim**: LazyVim 기반 Neovim 설정
- **tmux**: tmux 설정
- **zsh**: zsh 쉘 설정
- **git**: git 기본 설정
- **fzf**: fzf 설정

## 빠른 설치

### Mac (로컬)
```bash
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
./install.sh mac
```

### Linux Server
```bash
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
./install.sh server
```

## 수동 설치 단계

### 1. 필수 도구 설치

#### Mac
```bash
brew install neovim tmux fd fzf ripgrep stow node
curl -LsSf https://astral.sh/uv/install.sh | sh
```

#### Linux Server
```bash
# Neovim (최신 버전)
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod u+x nvim.appimage && sudo mv nvim.appimage /usr/local/bin/nvim

# 기타 도구
sudo apt update
sudo apt install -y tmux fd-find ripgrep stow nodejs npm

# uv 설치
curl -LsSf https://astral.sh/uv/install.sh | sh

# fzf 설치
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
```

### 2. Dotfiles 적용

```bash
cd ~/dotfiles
stow nvim tmux zsh git fzf
```

### 3. 환경별 설정

#### zsh PATH 설정
`~/.zshrc` 하단에 머신별 PATH 추가:
```bash
# 서버별 custom paths
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"  # uv 등
```

#### git 사용자 정보
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

## Stow 사용법

### 설정 적용
```bash
stow nvim  # ~/.config/nvim 심볼릭 링크 생성
```

### 설정 제거
```bash
stow -D nvim  # 심볼릭 링크 삭제
```

### 재적용
```bash
stow -R nvim  # 삭제 후 재생성
```

## 문제 해결

### "conflicts" 에러 발생 시
기존 파일 백업 후 재시도:
```bash
mv ~/.config/nvim ~/.config/nvim.backup
stow nvim
```

### fd 명령어 없음 (Ubuntu)
```bash
ln -s $(which fdfind) ~/.local/bin/fd
```
EOF

# 4. install.sh 생성
cat > "$DOTFILES_DIR/install.sh" << 'EOF'
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
EOF

chmod +x "$DOTFILES_DIR/install.sh"

# 5. .gitignore
cat > "$DOTFILES_DIR/.gitignore" << 'EOF'
# 백업 파일
*.backup.*

# OS 파일
.DS_Store
Thumbs.db

# 에디터
.vscode/
.idea/

# 임시 파일
*.swp
*.swo
*~
EOF

# 6. Git 초기화
cd "$DOTFILES_DIR"
git init
git add .
git commit -m "Initial dotfiles setup with stow"

echo ""
echo "✅ Dotfiles 저장소 생성 완료!"
echo "📍 위치: $DOTFILES_DIR"
echo ""
echo "📝 다음 단계:"
echo "1. GitHub에 새 저장소 만들기 (예: dotfiles)"
echo "2. cd $DOTFILES_DIR"
echo "3. git remote add origin git@github.com:username/dotfiles.git"
echo "4. git branch -M main"
echo "5. git push -u origin main"
