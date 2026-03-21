# openSUSE Tumbleweed Developer Setup

Automated setup script for openSUSE Tumbleweed, configuring a complete Hyprland-based development environment with modern tools, editors, and applications.

[![ShellCheck](https://github.com/engineervix/fedora-setup/actions/workflows/main.yml/badge.svg)](https://github.com/engineervix/fedora-setup/actions/workflows/main.yml)

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Environment](#environment)
- [Features](#features)
  - [🛠️ Development Tools](#-development-tools)
  - [📝 Editors & IDEs](#-editors--ides)
  - [🖥️ Terminal & Shell](#-terminal--shell)
  - [⚙️ Utilities & Applications](#-utilities--applications)
- [Installation](#installation)
- [Post-Installation](#post-installation)
- [References](#references)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Environment

A modular script architecture designed for a minimal Tumbleweed installation (Generic Desktop system role). It establishes a pure Wayland development environment using:

| Component | Choice |
| :--- | :--- |
| **Compositor** | Hyprland |
| **Status Bar** | Waybar |
| **Launcher** | Rofi-Wayland |
| **Terminal** | Kitty |
| **Editor** | Neovim (Kickstart-based) |

## Features

### 🛠️ Development Tools
- **Languages:** Python (pyenv/Poetry), Node.js (Volta), Go, Rust.
- **Containers:** Docker.
- **Cloud/CLI:** AWS CLI, Heroku CLI, GitHub/GitLab CLI.
- **VCS:** Git with `delta` and `lazygit`.

### 📝 Editors & IDEs
- **Neovim** (Kickstart, custom branch)
- **VS Code** (Official Repo)
- **Zed**

### 🖥️ Terminal & Shell
- **Zsh:** Default shell with Starship prompt, syntax highlighting, and autosuggestions.
- **Modern CLI:** `eza`, `bat`, `fd`, `ripgrep`, `zoxide`, `btop`, `fzf`.
- **Fonts:** JetBrains Mono, Fantasque Sans Mono, Cascadia Code (all Nerd Font variants).

### ⚙️ Utilities & Applications
- **Browsers:** Chromium, Google Chrome, Brave.
- **Media:** VLC, Spotify, Audacity, EasyEffects.
- **Communication:** Slack, Zoom.
- **Privacy:** DNS over TLS via Cloudflare.

## Installation

```bash
git clone https://github.com/engineervix/opensuse-setup.git
cd opensuse-setup/opensuse_setup
chmod +x install.sh scripts/*.sh
./install.sh
```

The setup runs five modular phases in sequence: System, Packages, Tooling, Fonts, Terminal.

## Post-Installation
1. **Fonts:** Set your terminal to use a Nerd Font (e.g., JetBrains Mono Nerd Font).
2. **Spotify:** Run `spotify-easyrpm` to complete the Spotify installation.
3. **Codecs:** Run `sudo opi codecs` to install restricted multimedia codecs (H.264, AAC, etc.).
4. **Reboot:** Essential to finalize group permissions (Docker) and start your Hyprland session via SDDM.

## References
- [Official openSUSE Documentation](https://en.opensuse.org/Main_Page)
- [Hyprland Wiki](https://wiki.hyprland.org/)
