# openSUSE Tumbleweed Developer Setup

![openSUSE](https://img.shields.io/badge/openSUSE-%2364B345?style=for-the-badge&logo=openSUSE&logoColor=white)
![Bash Script](https://img.shields.io/badge/bash_script-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white)
[![ShellCheck](https://github.com/engineervix/opensuse-setup/actions/workflows/main.yml/badge.svg)](https://github.com/engineervix/opensuse-setup/actions/workflows/main.yml)

Automated setup script for openSUSE Tumbleweed, configuring a complete Hyprland-based development environment with modern tools, editors, and applications.

## Stack

A modular script architecture designed for a minimal Tumbleweed installation (Generic Desktop system role). It establishes a pure Wayland development environment using:

| Component | Choice |
| :--- | :--- |
| **Compositor** | Hyprland |
| **Status Bar** | Waybar |
| **Launcher** | Rofi |
| **Terminal** | Kitty |
| **Editor** | Neovim (Kickstart-based) |

See [docs/details.md](docs/details.md) for a full breakdown of packages, configurations, and architectural decisions.

## Installation

```bash
git clone https://github.com/engineervix/opensuse-setup.git
cd opensuse-setup
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
