# openSUSE Tumbleweed + Hyprland: Setup Details

This document outlines the specific packages, configurations, and architectural choices made during the port from Fedora GNOME to openSUSE Tumbleweed with Hyprland.

## 🖥️ Graphical Environment (The "Hyprland Ecosystem")

Unlike GNOME's "all-in-one" approach, this setup uses modular Wayland components:

| Component         | Choice                  | Description                                                   |
| :---------------- | :---------------------- | :------------------------------------------------------------ |
| **Compositor**    | `hyprland`              | Dynamic tiling Wayland compositor. |
| **Critical Asset**| `hyprland-qtutils`      | Suppresses missing asset warnings when disabling standard zypper recommendations. |
| **Display Mgr**   | `sddm-qt6`              | Wayland-native display manager, replacing legacy sddm (Qt5).  |
| **Status Bar**    | `waybar`                | Highly customizable GTK bar.                                  |
| **App Launcher**  | `rofi-wayland`          | Application runner and menu system.                           |
| **Logout Menu**   | `wlogout`               | Highly customizable Wayland logout menu.                      |
| **Terminal**      | `kitty`                 | GPU-accelerated terminal. Static config managed in `conf/`. |
| **Night Light**   | `hyprsunset`            | Native Wayland blue-light filter.                             |

## 🛠️ Development Tooling

The setup translates Fedora's `dnf groups` into openSUSE `patterns` and installs specific version managers.

- **Build Essentials:** Installed via `devel_basis` and `devel_C_C++` patterns (includes `gcc`, `make`, `cmake`, `gdb`).
- **Node.js:** Managed by **Volta**. Includes global installs of:
  - `@google/gemini-cli`, `@marp-team/marp-cli`
  - `ccusage`, `commit-and-tag-version`, `doctoc`
  - `eslint`, `eslint-config-prettier`, `stylelint`
  - `gitlab-ci-local`, `pa11y`
  - `mdpdf`, `prettier`, `svgo`, `serve`
  - `neovim` (for node host support), `pyright`, `typescript`.
- **Python:** Managed by **pyenv**. Includes **Poetry** (with Zsh completions) and `virtualenvwrapper`.
- **Go:** Installed via Zypper. Includes `gopls` and `golangci-lint`.
- **Rust:** Managed via **rustup**.
- **Containers:** **Docker** and **Docker Compose** (enabled as a systemd service).
- **Cloud:** **AWS CLI v2** and **Heroku CLI**.

## 📝 Modern Text Editors

- **Neovim:** Replaced legacy Vim setup.
  - **Config:** Cloned from your custom branch: `engineervix/kickstart.nvim` (branch: `custom`).
- **VS Code:** Installed via the official Microsoft RPM repository.
- **Brave Browser:** Installed via the official Brave RPM repository.
- **Zed:** Installed via the official binary script.

## 🖥️ Shell & Terminal Customization

- **Shell:** `zsh` set as the default login shell.
- **Prompt:** **Starship** with the `catppuccin-powerline` preset.
- **Zsh Plugins:** Syntax highlighting and autosuggestions (using native openSUSE package paths).
- **Modern CLI Replacements:**
  - `ls` ➔ `eza` (with icons)
  - `cat` ➔ `bat`
  - `find` ➔ `fd`
  - `grep` ➔ `ripgrep`
  - `cd` ➔ `zoxide`
  - `top` ➔ `btop`
- **Fonts:**
  - JetBrains Mono Nerd Font
  - Fantasque Sans Mono Nerd Font
  - Cascadia Code (Nerd Font & Powerline variants)

## ⚙️ Utilities & Applications
The script installs a comprehensive suite of modern and essential tools:

- **Browsers:** Chromium, Google Chrome (official repo), Brave (official repo).
- **Communication:** Slack, Zoom.
- **Media:** 
  - VLC (with Packman Essentials codecs).
  - Spotify (Native RPM via `spotify-easyrpm`).
  - Audacity, yt-dlp.
  - EasyEffects (Native RPM from official repos).
- **Creative:** GIMP, Inkscape.
- **Productivity:** 
  - LibreOffice.
  - Okular, Xournal++, gscan2pdf for PDF/document management.
  - Meld for visual diffing.
  - Xiphos (Bible study tool).
- **System & Utility:**
  - GParted for partition management.
  - Transmission-GTK for BitTorrent.
  - Screenkey for screencasts.
  - DB Browser for SQLite, SQLite Browser.
  - `htop`, `btop` for monitoring.
- **API Client:** Bruno (Native RPM from official GitHub).

## 📂 Key File Locations
- **Main Entrypoint:** `opensuse_setup/install.sh`
- **Setup Modules:** `opensuse_setup/scripts/` (Sequence: 01_system, 02_packages, 03_tooling, 04_fonts, 05_terminal)
- **Static Configurations:** `opensuse_setup/conf/`
- **Neovim Config:** `~/.config/nvim/`
- **Waybar Config:** `~/.config/waybar/` (Requires user customization post-install)
- **Hyprland Config:** `~/.config/hypr/` (Requires user customization post-install)
- **Zsh Config:** `~/.zshrc` (Includes a robust set of Git and Docker aliases)
- **SourceGit:** Not pre-installed via package manager. It is recommended to download the **AppImage** from GitHub.

