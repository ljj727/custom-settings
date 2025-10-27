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
