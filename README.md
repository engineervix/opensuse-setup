# openSUSE Tumbleweed Developer Setup

Automated setup script for openSUSE Tumbleweed, configuring a complete Hyprland-based development environment with modern tools, editors, and applications.

## Environment

A modular script architecture designed for a minimal Tumbleweed installation (Generic Desktop system role). It establishes a pure Wayland development environment using:

| Component | Choice |
| :--- | :--- |
| **Compositor** | Hyprland |
| **Status Bar** | Waybar |
| **Launcher** | Rofi |
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
- **Browsers:** Chromium, Google Chrome, Brave, Zen.
- **Media:** VLC, Spotify, Audacity, EasyEffects.
- **Tools:** Screen Recording (`gpu-screen-recorder`).
- **Communication:** Slack.
- **Privacy:** DNS over TLS via Cloudflare.

## Installation

```bash
git clone https://github.com/engineervix/opensuse-setup.git
cd opensuse-setup/opensuse_setup
chmod +x install.sh scripts/*.sh
./install.sh
```

The setup runs six modular phases in sequence: System, Packages, Tooling, Fonts, Terminal, Dotfiles.

The script is interactive — it prompts for hostname, Git identity, and (in the Dotfiles phase) your dotfiles repository URL.

## Post-Installation
1. **Spotify:** Run `spotify-easyrpm` to complete the Spotify installation.
2. **Reboot:** Essential to finalize group permissions (Docker) and start your Hyprland session via SDDM.

## References
- [Official openSUSE Documentation](https://en.opensuse.org/Main_Page)
- [Hyprland Wiki](https://wiki.hyprland.org/)
