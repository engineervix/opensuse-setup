#!/usr/bin/env bash
# =============================================================================
# Script: 06_dotfiles.sh
# Description: Clones the dotfiles repository and runs its bootstrap script
#              to set up ~/.config symlinks.
# =============================================================================

log "--- [Phase 6: Dotfiles] ---"

DOTFILES_DIR="$HOME/dotfiles"

if [ -d "$DOTFILES_DIR/.git" ]; then
    info "Dotfiles repository already exists at ${DOTFILES_DIR}, skipping clone."
else
    read -rp "Enter your dotfiles repository URL (e.g. https://github.com/you/dotfiles.git): " DOTFILES_REPO
    if [ -z "$DOTFILES_REPO" ]; then
        warn "No dotfiles URL provided — skipping dotfiles setup."
        return 0
    fi
    log "Cloning dotfiles from ${DOTFILES_REPO}..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

BOOTSTRAP="${DOTFILES_DIR}/install.sh"

if [ ! -f "$BOOTSTRAP" ]; then
    warn "No install.sh found in ${DOTFILES_DIR} — skipping symlink setup."
    return 0
fi

chmod +x "$BOOTSTRAP"
log "Running dotfiles bootstrap..."
bash "$BOOTSTRAP"

# GTK dark theme — Hyprland has no settings daemon so gsettings is not read by
# GTK apps at runtime. Static ini files are the reliable fallback.
log "Writing GTK dark theme settings..."
mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"
for dir in gtk-3.0 gtk-4.0; do
    cat > "$HOME/.config/${dir}/settings.ini" <<'EOF'
[Settings]
gtk-application-prefer-dark-theme=1
gtk-theme-name=Adwaita-dark
EOF
done
