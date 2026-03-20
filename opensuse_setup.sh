#!/usr/bin/env bash

# =================================================================================================
# description:  openSUSE Tumbleweed Hyprland Developer Setup
# author:       Victor Miti <https://github.com/engineervix>
# url:          <https://github.com/engineervix/fedora-setup> (Ported to openSUSE)
# version:      1.0.0
# license:      MIT
#
# Usage: chmod +x opensuse_setup.sh && ./opensuse_setup.sh
# =================================================================================================

set -eo pipefail  # Exit immediately if any command or pipe fails

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

info() {
    echo -e "${CYAN}[INFO] $1${NC}"
}

log "Starting openSUSE Tumbleweed Developer Setup..."

# Verify we are on openSUSE
if ! grep -qi "opensuse" /etc/os-release; then
    warn "This script is designed for openSUSE Tumbleweed. You are not on openSUSE. Proceed with caution."
fi

# Refresh repositories and trust keys early
log "Refreshing repositories and trusting GPG keys..."
sudo zypper --gpg-auto-import-keys ref

# Set hostname
log "Let's set up a new hostname"
read -rp 'hostname: ' myhostname 
sudo hostnamectl set-hostname "$myhostname"

# Configure DNS over TLS for better privacy
setup_dns() {
    log "Setting up secure DNS with Cloudflare DNS over TLS..."
    sudo zypper in -y systemd-resolved
    sudo mkdir -p '/etc/systemd/resolved.conf.d'
    sudo tee '/etc/systemd/resolved.conf.d/99-dns-over-tls.conf' > /dev/null << 'EOF'
[Resolve]
DNS=1.1.1.2#security.cloudflare-dns.com 1.0.0.2#security.cloudflare-dns.com 2606:4700:4700::1112#security.cloudflare-dns.com 2606:4700:4700::1002#security.cloudflare-dns.com
DNSOverTLS=yes
EOF
    sudo systemctl enable --now systemd-resolved
    log "DNS over TLS configured with Cloudflare's security-focused DNS servers"
}
setup_dns

# Optimize zypper
log "Optimizing zypper configuration for faster downloads..."
sudo mkdir -p /etc/zypp
if [ ! -f /etc/zypp/zypp.conf ] || ! grep -q "download.max_concurrent_connections" /etc/zypp/zypp.conf; then
    echo "download.max_concurrent_connections = 10" | sudo tee -a /etc/zypp/zypp.conf
fi

# System update
log "Updating system packages..."
sudo zypper dup -y

# Setup Packman & OPI
log "Installing OPI (OBS Package Installer)..."
sudo zypper in -y opi

log "Adding Packman repository and forcing multimedia codec switch via OPI..."
# 'opi -n packman' is the modern way to handle this, as it resolves dependency deadlocks
# and performs the vendor switch automatically.
sudo opi -n packman

# Core Hyprland Desktop Environment
log "Installing Hyprland ecosystem components..."
sudo zypper in -y \
    hyprland \
    waybar \
    rofi-wayland \
    kitty \
    dunst \
    hyprpaper \
    polkit-kde-agent-6 \
    wl-clipboard \
    thunar \
    thunar-archive-plugin \
    xdg-desktop-portal-hyprland \
    sddm

# Development Patterns
log "Installing core development patterns and dependencies..."
sudo zypper in -y -t pattern devel_basis devel_C_C++ --no-recommends -x subversion -x git-svn

log "Installing core development packages..."
sudo zypper in -y \
    libbz2-devel \
    cmake \
    expat \
    libexpat-devel \
    gdbm-devel \
    gstreamer-devel \
    gstreamer-plugins-base-devel \
    libffi-devel \
    libpcap-devel \
    postgresql-devel \
    libyaml-devel \
    ncurses-devel \
    libopenssl-devel \
    mkcert \
    python3-devel \
    python3-pip \
    python3-virtualenvwrapper \
    python3-wheel \
    readline-devel \
    ruby-devel \
    sqlite3-devel \
    tk-devel \
    xz-devel \
    zlib-devel \
    python3-pipx

# Essential Tools
log "Installing utilities and applications..."
sudo zypper in -y \
    audacity \
    bat \
    btop \
    cifs-utils \
    duf \
    easyeffects \
    eza \
    fd \
    ffmpeg \
    fzf \
    gimp \
    git \
    gh \
    glab \
    gparted \
    gscan2pdf \
    htop \
    inkscape \
    jq \
    just \
    libva-utils \
    libreoffice \
    meld \
    ncdu \
    okular \
    pandoc \
    rclone \
    ripgrep \
    screenkey \
    ShellCheck \
    sqlitebrowser \
    tmux \
    tokei \
    transmission-gtk \
    vlc \
    vlc-codecs \
    xclip \
    xiphos \
    xournalpp \
    yq \
    yt-dlp \
    zoxide \
    zsh \
    zsh-syntax-highlighting \
    zsh-autosuggestions \
    zsh-completions

# Docker
log "Installing Docker..."
sudo zypper in -y docker docker-compose
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"

# Browsers
log "Installing Browsers..."
sudo zypper in -y chromium
# Google Chrome
sudo rpm --import https://dl-ssl.google.com/linux/linux_signing_key.pub
sudo zypper --gpg-auto-import-keys ar -f http://dl.google.com/linux/chrome/rpm/stable/x86_64 google-chrome || true
sudo zypper in -y google-chrome-stable
# Brave
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
sudo zypper --gpg-auto-import-keys ar -f https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo brave-browser || true
sudo zypper in -y brave-browser

# Spotify & Bruno (Native RPMs)
log "Installing Spotify and Bruno natively..."
# Spotify (via spotify-easyrpm)
sudo zypper --gpg-auto-import-keys ar -cfp 90 https://download.opensuse.org/repositories/home:megamaced/openSUSE_Tumbleweed/home:megamaced.repo || true
sudo zypper ref
sudo zypper in -y spotify-easyrpm
# We trigger the RPM build but non-interactively if possible, or just let the user know
info "To finish Spotify installation, run 'spotify-easyrpm' after the setup is complete."

# Bruno API Client
log "Downloading and installing latest Bruno RPM..."
BRUNO_LATEST_VERSION=$(curl -s https://api.github.com/repos/usebruno/bruno/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
BRUNO_DOWNLOAD_VERSION=${BRUNO_LATEST_VERSION#v}
wget -qO /tmp/bruno.rpm "https://github.com/usebruno/bruno/releases/download/$BRUNO_LATEST_VERSION/bruno_${BRUNO_DOWNLOAD_VERSION}_x86_64_linux.rpm"
sudo zypper in -y /tmp/bruno.rpm
rm -f /tmp/bruno.rpm

# Node.js development tools with Volta
log "Installing Volta for Node.js version management..."
if ! command -v volta &> /dev/null; then
    curl https://get.volta.sh | bash
    export VOLTA_HOME="$HOME/.volta"
    export PATH="$VOLTA_HOME/bin:$PATH"
    log "Installing Node.js and npm via Volta..."
    volta install node@lts
    volta install npm@latest
fi

log "Installing Node.js development tools..."
volta install \
    @google/gemini-cli \
    @marp-team/marp-cli \
    ccusage \
    commit-and-tag-version \
    doctoc \
    eslint \
    eslint-config-prettier \
    gitlab-ci-local \
    mdpdf \
    neovim \
    pa11y \
    prettier \
    pyright \
    serve \
    stylelint \
    svgo \
    typescript

# Communication tools (Slack, Zoom)
install_slack() {
    log "Starting Slack installation..."
    local download_url
    download_url=$(curl -sL "https://slack.com/downloads/instructions/linux?ddl=1&build=rpm" | grep -o 'https://downloads.slack-edge.com[^"]*\.rpm' | head -1)
    if [ -z "$download_url" ]; then
        error "Could not find Slack download URL"
        return 1
    fi
    info "Downloading Slack RPM package..."
    if curl -L -o "/tmp/slack.rpm" "$download_url"; then
        sudo zypper in --allow-unsigned-rpm -y /tmp/slack.rpm
        rm -f /tmp/slack.rpm
        log "Slack installed successfully"
    fi
}
install_slack

install_zoom() {
    log "Installing Zoom via automated download..."
    # Create temporary directory for zoom installer
    local temp_dir="/tmp/zoom-installer"
    mkdir -p "$temp_dir"
    cd "$temp_dir" || exit

    cat > package.json << 'EOF'
{
  "name": "zoom-downloader",
  "version": "1.0.0",
  "dependencies": {
    "playwright": "^1.54.1"
  }
}
EOF

    cat > zoom-download.js << 'EOF'
const { chromium } = require('playwright');
async function downloadZoom() {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();
  try {
    await page.goto('https://zoom.us/download?os=linux');
    await page.getByRole('button', { name: 'Accept Cookies' }).click().catch(() => {});
    await page.getByText('Please Select a Linux type').click();
    await page.getByText('openSUSE').click();
    await page.getByRole('button', { name: 'Download Zoom Workplace desktop app for Linux' }).click();
    const downloadPromise = page.waitForEvent('download');
    const download = await downloadPromise;
    const fileName = download.suggestedFilename();
    await download.saveAs(`./${fileName}`);
  } catch (error) {
    console.error('Download failed:', error);
    process.exit(1);
  } finally {
    await browser.close();
  }
}
downloadZoom();
EOF

    if volta run npm install && volta run npx playwright install chromium; then
        if volta run node zoom-download.js; then
            local rpm_file
            rpm_file=$(find . -name "zoom_*.rpm" | head -1)
            if [ -n "$rpm_file" ]; then
                sudo zypper in --allow-unsigned-rpm -y "$rpm_file"
                log "Zoom installed successfully"
            fi
        fi
    fi
    cd - > /dev/null
    rm -rf "$temp_dir"
}
install_zoom

# Neovim & Custom Kickstart
log "Setting up Neovim..."
sudo zypper in -y neovim gcc make ripgrep fd wl-clipboard xclip

if [ ! -d "$HOME/.config/nvim" ]; then
    log "Cloning custom kickstart.nvim configuration..."
    git clone -b custom https://github.com/engineervix/kickstart.nvim.git "$HOME/.config/nvim"
else
    info "Neovim configuration directory already exists, skipping clone."
fi

# Python, Go, Rust, AWS CLI
log "Installing pyenv for Python version management..."
if ! command -v pyenv &> /dev/null; then
    curl https://pyenv.run | bash
fi

log "Installing Poetry..."
export PATH="$PATH:$HOME/.local/bin"
pipx ensurepath
pipx install poetry
mkdir -p "$HOME/.zfunc/"
poetry completions bash >> ~/.bash_completion || true
poetry completions zsh > ~/.zfunc/_poetry || true

log "Installing Go..."
if ! command -v go &> /dev/null; then
    sudo zypper in -y go
fi
go install golang.org/x/tools/gopls@latest
gopath_bin="$(go env GOPATH)/bin"
GOPATH=$HOME/go curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/HEAD/install.sh | sh -s -- -b "$gopath_bin"

log "Installing Rust..."
if ! command -v rustc &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi

log "Installing AWS CLI..."
if ! command -v aws &> /dev/null; then
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
    unzip -q /tmp/awscliv2.zip -d /tmp/
    sudo /tmp/aws/install
    rm -rf /tmp/aws*
fi

# Fonts
log "Installing Nerd Fonts..."
mkdir -p "$HOME/.local/share/fonts"
if [ ! -f "$HOME/.local/share/fonts/JetBrainsMonoNerdFont-Regular.ttf" ]; then
    wget -qO /tmp/JetBrainsMono.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip
    unzip -q /tmp/JetBrainsMono.zip -d /tmp/JetBrainsMono/
    cp /tmp/JetBrainsMono/*.ttf "$HOME/.local/share/fonts/"
    rm -rf /tmp/JetBrainsMono*
fi

if [ ! -f "$HOME/.local/share/fonts/FantasqueSansMono Nerd Font Regular.ttf" ]; then
    wget -qO /tmp/FantasqueSansMono.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/FantasqueSansMono.zip
    unzip -q /tmp/FantasqueSansMono.zip -d /tmp/FantasqueSansMono/
    cp /tmp/FantasqueSansMono/*.ttf "$HOME/.local/share/fonts/"
    rm -rf /tmp/FantasqueSansMono*
fi

if [ ! -f "$HOME/.local/share/fonts/CascadiaCode-Regular.ttf" ]; then
    wget -qO /tmp/CascadiaCode.zip https://github.com/microsoft/cascadia-code/releases/download/v2407.24/CascadiaCode-2407.24.zip
    unzip -q /tmp/CascadiaCode.zip -d /tmp/CascadiaCode/
    cp /tmp/CascadiaCode/ttf/*.ttf "$HOME/.local/share/fonts/"
    cp /tmp/CascadiaCode/ttf/static/*.ttf "$HOME/.local/share/fonts/"
    rm -rf /tmp/CascadiaCode*
fi
fc-cache -fv

# Starship
log "Installing and configuring Starship..."
sudo zypper in -y starship
mkdir -p "$HOME/.config"
starship preset catppuccin-powerline -o "$HOME/.config/starship.toml"

# ZSH configuration
log "Configuring ZSH..."
if [[ -s "$HOME/.zshrc" ]]; then
    cp -v "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d-%H%M%S)"
fi

cat > "$HOME/.zshrc" << 'EOF'
# =============== Keybindings ===============
bindkey -e  # Use emacs key bindings
# vi-style word movement for Ctrl+Arrows
bindkey '^[[1;5C' vi-forward-word   # Ctrl+Right
bindkey '^[[1;5D' vi-backward-word  # Ctrl+Left
bindkey '^[[H' beginning-of-line    # Home
bindkey '^[[F' end-of-line          # End

# =============== Options ===============
setopt autocd              # Change directory by typing its name
setopt extendedglob        # Use extended globbing features
setopt interactivecomments # Allow comments in interactive shell
setopt magicequalsubst     # Filename expansion for arguments of the form 'anything=~'
setopt notify              # Report status of background jobs immediately
setopt numericglobsort     # Sort filenames numerically when globbing
setopt promptsubst         # Substitution in the prompt
setopt sharehistory        # Share history between different instances of zsh

# =============== History ===============
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt extended_history    # Save timestamps to history file
setopt appendhistory
setopt incappendhistory
setopt histignorealldups
setopt histignoredups
setopt histignorespace
setopt histreduceblanks
setopt histsavenodups

history() {
    if [[ $# -eq 0 ]]; then
        builtin history -i 1  # Show ISO 8601 timestamps (YYYY-MM-DD HH:MM)
    else
        builtin history "$@"
    fi
}

# =============== Paths ===============
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

# =============== Volta ===============
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# =============== Rust ===============
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# =============== Editor ===============
export VISUAL=nvim
export EDITOR="$VISUAL"

# =============== Pyenv ===============
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# =============== Virtualenvwrapper ===============
export WORKON_HOME="$HOME/.virtualenvs"
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
for wrapper in /usr/bin/virtualenvwrapper.sh /usr/local/bin/virtualenvwrapper.sh; do
    [ -f "$wrapper" ] && source "$wrapper" && break
done

# =============== Go ===============
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# =============== Completions ===============
fpath+=~/.zfunc
export FPATH="$HOME/.local/share/eza-completions/zsh:$FPATH"

# Enable completion cache
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
# Case insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

autoload -Uz compinit
for dump in ~/.zcompdump(N.mh+24); do
  compinit
done
compinit -C

# =============== Aliases ===============
# General
alias open="xdg-open"
alias ls='eza --icons'
alias ll='eza -la --icons'
alias la='eza -lah --icons'
alias cat='bat'
alias find='fd'
alias grep='rg'
alias du='duf'
alias top='btop'
alias cd='z'
alias ts='date +"%Y-%m-%d-%H-%M-%S"'
alias trash='gio trash'
alias pipup='pip install --upgrade pip'

# Safety aliases
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Git Helper Functions
function git_current_branch() {
  git symbolic-ref --short -q HEAD
}

function git_main_branch() {
  command git rev-parse --git-dir &>/dev/null || return
  local ref
  for ref in refs/{heads,remotes/{origin,upstream}}/{main,trunk,mainline,default,stable,master}; do
    if command git show-ref -q --verify $ref; then
      echo ${ref:t}
      return 0
    fi
  done
  echo master
}

# Git Aliases
alias g='git'
alias gst='git status'
alias gss='git status --short'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit --verbose'
alias gcmsg='git commit --message'
alias gca='git commit --verbose --all'
alias gc!='git commit --verbose --amend'
alias gb='git branch'
alias gba='git branch --all'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gcm='git checkout $(git_main_branch)'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git pull'
alias gp='git push'
alias glog='git log --oneline --decorate --graph'
alias glol='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset"'

# Docker Aliases
alias dco="docker compose"
alias dps='docker ps'
alias dpsa='docker ps -a'
alias dcu='docker compose up'
alias dcud='docker compose up -d'
alias dcd='docker compose down'

# =============== Custom Functions ===============
mkcd() { mkdir -p "$1" && cd "$1"; }

extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar e "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)     echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

tar_max() {
  tar --exclude='.DS_Store' --exclude='node_modules' --exclude='__pycache__' -cv "$1" | xz -3e > "$2".tar.xz
}

grep_this() {
  grep --color -inrw . -e "$1"
  echo "Matches: $(grep -inrw . -e "$1" | wc -l)"
}

mkdir_date() {
  mkdir -p $(date '+%Y-%h-%d-%a')
}

kill_spaces() {
  find . -name "**.$1" -type f -print0 | while read -d $'\0' f; do mv -v "$f" "${f// /_}"; done
}

# PDF Management
encrypt_pdf() {
  encrypted_pdf="${1%.pdf}.128.pdf"
  pdftk "$1" output ${encrypted_pdf} owner_pw "$2" allow printing verbose
  mv -v "$1" "${1%.pdf}_src.pdf"
  mv -v ${encrypted_pdf} "${encrypted_pdf%.128.pdf}.pdf"
}

split_pdf() {
  split_files="${1%.pdf}_%02d.pdf"
  pdftk "$1" burst output ${split_files} verbose
}

grep_pdf() {
  find . -iname '*.pdf' | while read filename
  do
    pdftotext -enc Latin1 "$filename" - | grep --with-filename --label="$filename" --color -i "$1"
  done
}

function add_nodemodules_bin() {
    local bin_path="./node_modules/.bin"
    if [[ -d "$bin_path" && ":$PATH:" != *":$bin_path:"* ]]; then
        export PATH="$bin_path:$PATH"
    fi
}
autoload -U add-zsh-hook
add-zsh-hook chpwd add_nodemodules_bin

# =============== FZF, Zoxide, Starship ===============
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"

# ============ syntax highlighting & autosuggestions =============
[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] && source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# =============== Local / Secret Config ===============
# Keep secrets and machine-specific config in .zshrc.local
# This file should NOT be tracked by git.
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
EOF

# Change default shell
log "Changing default shell to zsh..."
sudo chsh -s "$(which zsh)" "$USER"

# Cleanup
log "Cleaning up package cache..."
sudo zypper clean

log "==========================================================="
log "Setup Complete! 🎉"
log "==========================================================="
info "We have successfully:"
info "  1. Installed Hyprland, Waybar, Rofi, and Kitty"
info "  2. Cloned your custom Neovim setup (kickstart.nvim, custom branch)"
info "  3. Set up Zsh, eza, Starship, and all development tooling"
info "  4. Configured Docker, Node, Python, Go, and Rust"
echo
warn "IMPORTANT: A reboot is required to fully apply group changes (Docker) and start your new graphical session."
info "After reboot, select 'Hyprland' from your login manager (SDDM/GDM) or launch it from the TTY."
echo
read -rp "Press Enter to reboot now, or Ctrl+C to reboot manually later..."
sudo reboot
