#!/usr/bin/env bash
# =============================================================================
# Script: 04_fonts.sh
# Description: Downloads and installs Nerd Fonts for terminal rendering.
# =============================================================================

log "--- [Phase 4: Font Installation] ---"

log "Installing Nerd Fonts..."
mkdir -p "$HOME/.local/share/fonts"

# JetBrains Mono
if [ ! -f "$HOME/.local/share/fonts/JetBrainsMonoNerdFont-Regular.ttf" ]; then
    info "Downloading JetBrainsMono Nerd Font..."
    wget -qO /tmp/JetBrainsMono.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip
    unzip -q /tmp/JetBrainsMono.zip -d /tmp/JetBrainsMono/
    cp /tmp/JetBrainsMono/*.ttf "$HOME/.local/share/fonts/"
    rm -rf /tmp/JetBrainsMono*
fi

# Fantasque Sans Mono
if [ ! -f "$HOME/.local/share/fonts/FantasqueSansMono Nerd Font Regular.ttf" ]; then
    info "Downloading FantasqueSansMono Nerd Font..."
    wget -qO /tmp/FantasqueSansMono.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/FantasqueSansMono.zip
    unzip -q /tmp/FantasqueSansMono.zip -d /tmp/FantasqueSansMono/
    cp /tmp/FantasqueSansMono/*.ttf "$HOME/.local/share/fonts/"
    rm -rf /tmp/FantasqueSansMono*
fi

# Cascadia Code (Nerd Font patched variant — "CaskaydiaCode" in nerd-fonts)
if [ ! -f "$HOME/.local/share/fonts/CaskaydiaCodeNerdFont-Regular.ttf" ]; then
    info "Downloading CaskaydiaCode Nerd Font..."
    wget -qO /tmp/CascadiaCode.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/CascadiaCode.zip
    unzip -q /tmp/CascadiaCode.zip -d /tmp/CascadiaCode/
    cp /tmp/CascadiaCode/*.ttf "$HOME/.local/share/fonts/"
    rm -rf /tmp/CascadiaCode*
fi

log "Refreshing font cache..."
fc-cache -fv
