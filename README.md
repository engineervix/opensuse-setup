# Linux Developer Setup

Automated setup scripts for Fedora and openSUSE Tumbleweed, configuring a complete development environment with modern tools, editors, and applications.

[![ShellCheck](https://github.com/engineervix/fedora-setup/actions/workflows/main.yml/badge.svg)](https://github.com/engineervix/fedora-setup/actions/workflows/main.yml)

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Environments](#environments)
  - [Fedora (GNOME)](#fedora-gnome)
  - [openSUSE Tumbleweed (Hyprland)](#opensuse-tumbleweed-hyprland)
- [Shared Features](#shared-features)
  - [🛠️ Development Tools](#-development-tools)
  - [📝 Editors & IDEs](#-editors--ides)
  - [🖥️ Terminal & Shell](#-terminal--shell)
  - [⚙️ Utilities & Applications](#-utilities--applications)
- [Installation](#installation)
  - [Fedora Setup](#fedora-setup)
  - [openSUSE Setup](#opensuse-setup)
- [Post-Installation](#post-installation)
- [References](#references)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Environments

### Fedora (GNOME)
A two-part setup for Fedora 42/43 Workstation. It optimizes DNF, configures GNOME shell tweaks, and installs a comprehensive set of development libraries and GNOME-specific utilities.

### openSUSE Tumbleweed (Hyprland)
A modular script architecture specifically designed for a minimal Tumbleweed installation (Generic Desktop system role). It establishes a pure Wayland development environment using:
- **Compositor:** Hyprland
- **Status Bar:** Waybar
- **Launcher:** Rofi-Wayland
- **Terminal:** Kitty
- **Editor:** Neovim (Kickstart-based)

## Shared Features

### 🛠️ Development Tools
- **Languages:** Python (pyenv/Poetry), Node.js (Volta), Go, Rust.
- **Containers:** Docker with `ctop`.
- **Cloud/CLI:** AWS CLI, Heroku CLI, GitHub/GitLab CLI.
- **VCS:** Git with `delta` and `lazygit`.

### 📝 Editors & IDEs
- **VS Code** (Official Repo)
- **Zed** & **Cursor** (Optional)
- **Neovim/Vim:** Tailored for the specific distro (Kickstart for openSUSE, Vim-plug for Fedora).

### 🖥️ Terminal & Shell
- **Zsh:** Default shell with Starship prompt, syntax highlighting, and autosuggestions.
- **Modern CLI:** `eza`, `bat`, `fd`, `ripgrep`, `zoxide`, `btop`, `fzf`.
- **Fonts:** JetBrains Mono, Fantasque Sans Mono, Cascadia Code Nerd Fonts.

### ⚙️ Utilities & Applications
- **Browsers:** Chromium, Google Chrome, Brave.
- **Media:** VLC, Spotify, Audacity, EasyEffects.
- **Communication:** Slack, Zoom.
- **Privacy:** DNS over TLS via Cloudflare.

## Installation

First, clone the repository:
```bash
git clone https://github.com/engineervix/fedora-setup.git
cd fedora-setup
```

### Fedora Setup
The Fedora setup requires a reboot between parts to finalize the shell change.
```bash
chmod +x fedora_setup_part1.sh fedora_setup_part2.sh
./fedora_setup_part1.sh
# Reboot, then run:
./fedora_setup_part2.sh
```

### openSUSE Setup
The openSUSE setup is broken down into modular phases (System, Packages, Tooling, Fonts, Terminal) driven by a single entry point.
```bash
cd opensuse_setup
chmod +x install.sh scripts/*.sh
./install.sh
```

## Post-Installation
1. **Fonts:** Set your terminal to use a Nerd Font (e.g., JetBrains Mono Nerd Font).
2. **Spotify:** Run `lpf update` (Fedora) or follow the installed client instructions.
3. **Browser:** Enable Hardware Acceleration and OpenH264 in Firefox if used.
4. **Reboot:** Essential to finalize group permissions (Docker) and environment variables.

## References
- [Official openSUSE Documentation](https://en.opensuse.org/Main_Page)
- [Hyprland Wiki](https://wiki.hyprland.org/)
- [Fedora Post-Install Guide](https://github.com/devangshekhawat/Fedora-42-Post-Install-Guide)
