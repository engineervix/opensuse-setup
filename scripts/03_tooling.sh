#!/usr/bin/env bash
# =============================================================================
# Script: 03_tooling.sh
# Description: Configures development tooling environments (Node, Python, Go,
#              Rust, AWS) and sets up Neovim.
# =============================================================================

log "--- [Phase 3: Development Tooling] ---"

# Node.js development tools with Vite+ (vp), which replaces the unmaintained Volta.
# It manages Node.js and npm/pnpm/yarn/bun, and pins each global CLI to the Node
# LTS it was installed with.
log "Installing Vite+ for Node.js version management..."
if ! command -v vp &>/dev/null; then
  vp_installer="$(mktemp)"
  curl -fsSL https://vite.plus -o "$vp_installer"
  # Source the installer in a subshell: it defines its own info/warn/error helpers,
  # and when sourced it sets SHIM_DIR (where `vp` lands), which `curl | bash` loses.
  # VP_NODE_MANAGER/VP_PM_MANAGER=yes answer its prompts so Vite+ manages Node.js and
  # the package managers (otherwise a pnpm already on PATH would stay unmanaged).
  vp_shim_dir="$(
    set +o pipefail
    export VP_NODE_MANAGER=yes VP_PM_MANAGER=yes
    # shellcheck disable=SC1090
    source "$vp_installer" >&2
    printf '%s' "${SHIM_DIR:-}"
  )"
  rm -f "$vp_installer"
  if [[ ! -x "$vp_shim_dir/vp" ]]; then
    error "Vite+ installed but vp was not found in '$vp_shim_dir'"
    exit 1
  fi
  export PATH="$vp_shim_dir:$PATH"
fi

log "Installing Node.js development tools..."
# pnpm is not listed: Vite+ provides its own pnpm shim and drops a global
# package's pnpm/pnpx bins as conflicting with it.
vp_packages=(
  @apollo/rover
  @marp-team/marp-cli
  @vtsls/language-server
  ccusage
  commit-and-tag-version
  doctoc
  eslint
  eslint-config-prettier
  gitlab-ci-local
  hunkdiff
  heroku
  jscpd
  mdpdf
  neovim
  pa11y
  prettier
  pyright
  serve
  stylelint
  svgo
  typescript
)
# `vp list -g` rows look like `prettier@3.9.10  26.13.0  prettier`; keep the bare names.
vp_installed="$(vp list -g 2>/dev/null | awk '{print $1}' | sed -n 's/@[^@]*$//p' || true)"
for pkg in "${vp_packages[@]}"; do
  if grep -qxF -- "$pkg" <<<"$vp_installed"; then
    continue
  fi
  # --node lts resolves to the newest LTS now and pins the tool to that exact version.
  vp install -g --node lts "$pkg"
done

# Python
log "Installing pyenv for Python version management..."
if ! command -v pyenv &>/dev/null; then
  curl https://pyenv.run | bash
fi

log "Installing uv..."
if ! command -v uv &>/dev/null; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
fi

log "Installing Poetry and virtualenvwrapper..."
export PATH="$PATH:$HOME/.local/bin"
pipx ensurepath
if ! pipx list --short | grep -q "poetry"; then
  pipx install poetry
fi
sudo zypper in -y python313-virtualenvwrapper
mkdir -p "$HOME/.zfunc/"
grep -qF '_poetry' ~/.bash_completion 2>/dev/null || poetry completions bash >>~/.bash_completion || true
poetry completions zsh >~/.zfunc/_poetry || true

# Python tools
log "Installing additional Python tools via pipx..."
for pkg in timetagger_cli lefthook ggshield; do
  if ! pipx list --short | grep -q "$pkg"; then
    pipx install "$pkg"
  fi
done

# Ruby
log "Installing rbenv for Ruby version management..."
if [ ! -d "$HOME/.rbenv" ]; then
  curl -fsSL https://rbenv.org/install.sh | bash
fi

if ! "$HOME/.rbenv/bin/rbenv" global 2>/dev/null | grep -qv 'system'; then
  RUBY_VERSION=$("$HOME/.rbenv/bin/rbenv" install -l 2>/dev/null | awk '/^[0-9]+\.[0-9]+\.[0-9]+$/' | tail -1)
  "$HOME/.rbenv/bin/rbenv" install "$RUBY_VERSION"
  "$HOME/.rbenv/bin/rbenv" global "$RUBY_VERSION"
fi

log "Installing Ruby gems..."
gem install try-cli

# Go
log "Installing Go and related tools..."
if ! command -v go &>/dev/null; then
  sudo zypper in -y go
fi
go install golang.org/x/tools/gopls@latest
gopath_bin="$(go env GOPATH)/bin"
GOPATH=$HOME/go curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/HEAD/install.sh | sh -s -- -b "$gopath_bin"

log "Installing diffnav (delta-based git diff pager with file tree)..."
# go.mod carries replace directives, which `go install ...@latest` rejects, so build from a clone instead.
DIFFNAV_BUILD_DIR="$(mktemp -d)"
git clone https://github.com/dlvhdr/diffnav "$DIFFNAV_BUILD_DIR"
(
  cd "$DIFFNAV_BUILD_DIR" || exit
  LATEST_TAG=$(git describe --tags "$(git rev-list --tags --max-count=1)")
  git checkout "$LATEST_TAG"
  go install .
)
rm -rf "$DIFFNAV_BUILD_DIR"
git config --global pager.diff diffnav

# Rust ecosystem (rustup itself is installed earlier, in 02_packages.sh)
log "Installing Rust ecosystem..."
# We need this for the Neovim setup
if ! command -v tree-sitter &>/dev/null; then
  cargo install tree-sitter-cli
fi

# AWS CLI
log "Installing AWS CLI..."
if ! command -v aws &>/dev/null; then
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
  unzip -q /tmp/awscliv2.zip -d /tmp/
  sudo /tmp/aws/install
  rm -rf /tmp/aws*
fi

# ctop (Container monitoring)
log "Installing ctop..."
if ! command -v ctop &>/dev/null; then
  sudo wget -qO /usr/local/bin/ctop https://github.com/bcicen/ctop/releases/download/v0.7.7/ctop-0.7.7-linux-amd64
  sudo chmod +x /usr/local/bin/ctop
fi

# presenterm (terminal presentation tool)
log "Installing presenterm..."
if ! command -v presenterm &>/dev/null; then
  PRESENTERM_VERSION=$(curl -s https://api.github.com/repos/mfontanini/presenterm/releases/latest | grep '"tag_name"' | cut -d'"' -f4 | sed 's/^v//')
  mkdir -p "$HOME/bin"
  curl -fsSL "https://github.com/mfontanini/presenterm/releases/download/v${PRESENTERM_VERSION}/presenterm-${PRESENTERM_VERSION}-x86_64-unknown-linux-musl.tar.gz" |
    tar -xz --strip-components=1 -C "$HOME/bin" "presenterm-${PRESENTERM_VERSION}-x86_64-unknown-linux-musl/presenterm"
fi

# nb (plain-text notes, bookmarks, and todos, git-backed - single-script CLI)
log "Installing nb..."
if ! command -v nb &>/dev/null; then
  NB_VERSION=$(curl -s https://api.github.com/repos/xwmx/nb/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
  mkdir -p "$HOME/.local/bin" "$HOME/.zfunc"
  curl -fsSL "https://github.com/xwmx/nb/releases/download/${NB_VERSION}/nb" -o "$HOME/.local/bin/nb"
  chmod +x "$HOME/.local/bin/nb"
  curl -fsSL "https://raw.githubusercontent.com/xwmx/nb/${NB_VERSION}/etc/nb-completion.zsh" -o "$HOME/.zfunc/_nb"
fi

# Terraform
log "Installing Terraform..."
if ! command -v terraform &>/dev/null; then
  TERRAFORM_VERSION=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r .current_version)
  curl -Lo /tmp/terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
  unzip -q /tmp/terraform.zip -d /tmp/
  sudo mv /tmp/terraform /usr/local/bin/
  rm /tmp/terraform.zip
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
if ! command -v zed &>/dev/null; then
  curl -f https://zed.dev/install.sh | sh
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
if vim --not-a-term -c 'PlugInstall --sync | qa!' >/tmp/vim-plug-install.log 2>&1; then
  log "Vim plugins installed successfully"

  # Check if YouCompleteMe needs manual compilation (fallback)
  if [ -d "$HOME/.vim/plugged/YouCompleteMe" ] && [ ! -f "$HOME/.vim/plugged/YouCompleteMe/third_party/ycmd/ycm_core.so" ]; then
    log "Compiling YouCompleteMe manually..."
    (
      cd "$HOME/.vim/plugged/YouCompleteMe" || exit
      if python3 install.py >/tmp/ycm-install.log 2>&1; then
        log "YouCompleteMe compiled successfully"
      else
        warn "YouCompleteMe compilation had issues - check /tmp/ycm-install.log"
        warn "You may need to install additional development packages"
      fi
    )
  fi

  # Install Go binaries for vim-go
  if [ -d "$HOME/.vim/plugged/vim-go" ]; then
    log "Installing vim-go binaries..."
    vim --not-a-term -c 'GoUpdateBinaries | qa!' >/tmp/vim-go-install.log 2>&1 ||
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
