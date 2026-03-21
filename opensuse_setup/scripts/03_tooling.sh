#!/usr/bin/env bash
# =============================================================================
# Script: 03_tooling.sh
# Description: Configures development tooling environments (Node, Python, Go, 
#              Rust, AWS) and sets up Neovim.
# =============================================================================

log "--- [Phase 3: Development Tooling] ---"

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
if ! volta list 2>/dev/null | grep -q 'prettier'; then
volta install \
    @google/gemini-cli \
    @marp-team/marp-cli \
    ccusage \
    commit-and-tag-version \
    doctoc \
    eslint \
    eslint-config-prettier \
    gitlab-ci-local \
    heroku \
    mdpdf \
    neovim \
    pa11y \
    prettier \
    pyright \
    serve \
    stylelint \
    svgo \
    typescript
fi

# Python
log "Installing pyenv for Python version management..."
if ! command -v pyenv &> /dev/null; then
    curl https://pyenv.run | bash
fi

log "Installing Poetry and virtualenvwrapper..."
export PATH="$PATH:$HOME/.local/bin"
pipx ensurepath
pipx install poetry
pipx install virtualenvwrapper
mkdir -p "$HOME/.zfunc/"
grep -qF '_poetry' ~/.bash_completion 2>/dev/null || poetry completions bash >> ~/.bash_completion || true
poetry completions zsh > ~/.zfunc/_poetry || true

# Go
log "Installing Go and related tools..."
if ! command -v go &> /dev/null; then
    sudo zypper in -y go
fi
go install golang.org/x/tools/gopls@latest
gopath_bin="$(go env GOPATH)/bin"
GOPATH=$HOME/go curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/HEAD/install.sh | sh -s -- -b "$gopath_bin"

# Rust
log "Installing Rust ecosystem..."
if ! command -v rustc &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi

# AWS CLI
log "Installing AWS CLI..."
if ! command -v aws &> /dev/null; then
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
    unzip -q /tmp/awscliv2.zip -d /tmp/
    sudo /tmp/aws/install
    rm -rf /tmp/aws*
fi

# ctop (Container monitoring)
log "Installing ctop..."
if ! command -v ctop &> /dev/null; then
    sudo wget -qO /usr/local/bin/ctop https://github.com/bcicen/ctop/releases/download/v0.7.7/ctop-0.7.7-linux-amd64
    sudo chmod +x /usr/local/bin/ctop
fi

# Zed Editor
log "Installing Zed editor..."
if ! command -v zed &> /dev/null; then
    curl -f https://zed.dev/install.sh | sh
fi

# Neovim & Custom Kickstart
log "Setting up Neovim compiler dependencies (gcc, make) and utilities..."
sudo zypper in -y neovim gcc make ripgrep fd wl-clipboard xclip

if [ ! -d "$HOME/.config/nvim" ]; then
    log "Cloning custom kickstart.nvim configuration..."
    git clone -b custom https://github.com/engineervix/kickstart.nvim.git "$HOME/.config/nvim"
else
    info "Neovim configuration directory already exists, skipping clone."
fi
