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
2. **Reboot:** Required to start your Hyprland session via SDDM.
3. **gpu-screen-recorder:** If it fails with `version LIBAVFILTER_X.Y_SUSE not found` after a Packman ffmpeg update, run `scripts/rebuild-gpu-screen-recorder.sh`.

## Optional: LocalSend

No openSUSE package exists, so build it from source (slow first run, not part of `install.sh`):

```bash
scripts/localsend-build.sh
```

Re-run to upgrade to the latest release tag. The installed `localsend` is a wrapper that opens port 53317 (TCP+UDP, runtime only) via `firewall-cmd` while the app runs and closes it on exit. polkit prompts for your password on launch.

## References
- [Official openSUSE Documentation](https://en.opensuse.org/Main_Page)
- [Hyprland Wiki](https://wiki.hyprland.org/)
