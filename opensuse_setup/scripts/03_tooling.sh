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
sudo zypper in -y python313-virtualenvwrapper
mkdir -p "$HOME/.zfunc/"
grep -qF '_poetry' ~/.bash_completion 2>/dev/null || poetry completions bash >> ~/.bash_completion || true
poetry completions zsh > ~/.zfunc/_poetry || true

# time tracking
pipx install timetagger_cli

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
# Ensure cargo is available in this session
source "$HOME/.cargo/env"
# We need this for the Neovim setup
if ! command -v tree-sitter &>/dev/null; then
    cargo install tree-sitter-cli
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

# Neovim & Custom Kickstart
log "Setting up Neovim compiler dependencies (gcc, make) and utilities..."
sudo zypper in -y neovim gcc make ripgrep fd wl-clipboard xclip

if [ ! -d "$HOME/.config/nvim" ]; then
    log "Cloning custom kickstart.nvim configuration..."
    git clone -b custom https://github.com/engineervix/kickstart.nvim.git "$HOME/.config/nvim"
else
    info "Neovim configuration directory already exists, skipping clone."
fi

# Zed Editor
log "Installing Zed editor..."
if ! command -v zed &> /dev/null; then
    curl -f https://zed.dev/install.sh | sh
fi

# antigravity
log "Installing antigravity..."
if ! zypper repos | grep -q "antigravity-rpm"; then
    sudo zypper addrepo --no-gpgcheck https://us-central1-yum.pkg.dev/projects/antigravity-auto-updater-dev/antigravity-rpm antigravity-rpm
fi
if ! command -v antigravity &> /dev/null; then
    sudo zypper in -y antigravity
fi

# Visual Studio Code
log "Installing Visual Studio Code..."
if ! zypper repos --uri | grep -q "packages.microsoft.com/yumrepos/vscode"; then
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/zypp/repos.d/vscode.repo > /dev/null
fi
if ! command -v code &>/dev/null; then
    sudo zypper in -y code
fi

# Vim configuration
log "Configuring Vim..."
cp "${SCRIPT_DIR}/conf/vimrc" "$HOME/.vimrc"

# Install vim-plug
log "Installing vim-plug plugin manager..."
if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
    curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    log "vim-plug installed successfully"
else
    info "vim-plug already installed, skipping..."
fi

# Install vim plugins
log "Installing vim plugins (this may take a few minutes)..."
info "Note: YouCompleteMe will compile in the background - this is normal and may take some time"

# Install plugins in a more controlled way
if vim --not-a-term -c 'PlugInstall --sync | qa!' > /tmp/vim-plug-install.log 2>&1; then
    log "Vim plugins installed successfully"

    # Check if YouCompleteMe needs manual compilation (fallback)
    if [ -d "$HOME/.vim/plugged/YouCompleteMe" ] && [ ! -f "$HOME/.vim/plugged/YouCompleteMe/third_party/ycmd/ycm_core.so" ]; then
        log "Compiling YouCompleteMe manually..."
        cd "$HOME/.vim/plugged/YouCompleteMe"
        if python3 install.py > /tmp/ycm-install.log 2>&1; then
            log "YouCompleteMe compiled successfully"
        else
            warn "YouCompleteMe compilation had issues - check /tmp/ycm-install.log"
            warn "You may need to install additional development packages"
        fi
        cd - > /dev/null
    fi

    # Install Go binaries for vim-go
    if [ -d "$HOME/.vim/plugged/vim-go" ]; then
        log "Installing vim-go binaries..."
        vim --not-a-term -c 'GoUpdateBinaries | qa!' > /tmp/vim-go-install.log 2>&1 || \
            warn "vim-go binaries may need manual install - run ':GoUpdateBinaries' in vim"
    fi
else
    warn "Some vim plugins may not have installed correctly - check /tmp/vim-plug-install.log"
    warn "You can manually run ':PlugInstall' in vim to retry"
fi

log "Vim setup completed! Use ':NERDTree' to open file explorer, ':Files' for fuzzy finding."

# Zen Browser (replaces Firefox)
log "Installing Zen Browser (also uninstalls firefox)..."
if ! command -v zen &>/dev/null; then
    sudo zypper rm -y firefox 2>/dev/null || true
    curl -fsSL https://github.com/zen-browser/updates-server/raw/refs/heads/main/install.sh | $SHELL
fi
