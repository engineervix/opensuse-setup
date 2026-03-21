#!/usr/bin/env bash
# =============================================================================
# Script: 05_terminal.sh
# Description: Configures Zsh, installs plugins, sets up Starship prompt,
#              and configures Kitty terminal.
# =============================================================================

log "--- [Phase 5: Terminal Configuration] ---"

# Starship
log "Installing and configuring Starship prompt..."
sudo zypper in -y starship
mkdir -p "$HOME/.config"

# Kitty Configuration
log "Configuring Kitty terminal..."
mkdir -p "$HOME/.config/kitty"
cp "${SCRIPT_DIR}/conf/kitty.conf" "$HOME/.config/kitty/kitty.conf"

log "Downloading Catppuccin Mocha theme for Kitty..."
curl -sL https://raw.githubusercontent.com/catppuccin/kitty/main/themes/mocha.conf -o "$HOME/.config/kitty/mocha.conf"

# ZSH plugins (not in standard Tumbleweed repos)
log "Installing ZSH plugins from source..."
mkdir -p "$HOME/.zsh"
[ -d "$HOME/.zsh/zsh-syntax-highlighting" ] || git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.zsh/zsh-syntax-highlighting"
[ -d "$HOME/.zsh/zsh-autosuggestions" ]     || git clone https://github.com/zsh-users/zsh-autosuggestions.git "$HOME/.zsh/zsh-autosuggestions"
[ -d "$HOME/.zsh/zsh-completions" ]         || git clone https://github.com/zsh-users/zsh-completions.git "$HOME/.zsh/zsh-completions"

# ZSH configuration
log "Configuring ZSH..."
if [[ -s "$HOME/.zshrc" ]]; then
    cp -v "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d-%H%M%S)"
fi

cp "${SCRIPT_DIR}/conf/zshrc_template" "$HOME/.zshrc"

# Change default shell
log "Changing default shell to zsh..."
sudo chsh -s "$(which zsh)" "$USER"
