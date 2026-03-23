#!/usr/bin/env bash

# =================================================================================================
# description:  openSUSE Tumbleweed Hyprland Developer Setup (Modular)
# author:       Victor Miti <https://github.com/engineervix>
# version:      2.0.0
# license:      MIT
#
# Usage: chmod +x install.sh && ./install.sh
# =================================================================================================

set -eo pipefail  # Exit immediately if any command or pipe fails

# -----------------------------------------------------------------------------
# Global Color & Logging Configuration
# -----------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

export RED GREEN YELLOW CYAN NC

log()   { echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"; }
warn()  { echo -e "${YELLOW}[WARNING] $1${NC}"; }
error() { echo -e "${RED}[ERROR] $1${NC}"; }
info()  { echo -e "${CYAN}[INFO] $1${NC}"; }

export -f log warn error info

# -----------------------------------------------------------------------------
# Main Execution Flow
# -----------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log "Starting openSUSE Tumbleweed Developer Setup..."

# Verify we are on openSUSE
if ! grep -qi "opensuse" /etc/os-release; then
    warn "This script is designed for openSUSE Tumbleweed. You are not on openSUSE. Proceed with caution."
fi

info "Executing modular setup scripts..."

source "${SCRIPT_DIR}/scripts/01_system.sh"
source "${SCRIPT_DIR}/scripts/02_packages.sh"
source "${SCRIPT_DIR}/scripts/03_tooling.sh"
source "${SCRIPT_DIR}/scripts/04_fonts.sh"
source "${SCRIPT_DIR}/scripts/05_terminal.sh"
source "${SCRIPT_DIR}/scripts/06_dotfiles.sh"

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
info "  5. Cloned dotfiles and set up ~/.config symlinks"
echo
warn "IMPORTANT: A reboot is required to fully apply group changes (Docker) and start your new graphical session."
info "After reboot, select 'Hyprland' from your login manager (SDDM) or launch it from the TTY."
warn "For restricted multimedia codecs (H.264, AAC, etc.), run 'sudo opi codecs' after rebooting."
warn "SELinux & Docker volumes: If containers can't access mounted volumes, run 'chcon -R -t container_file_t .' in the project directory"
echo
read -rp "Press Enter to reboot now, or Ctrl+C to reboot manually later..."
sudo reboot
