# openSUSE Tumbleweed + Hyprland: Setup Details

This document outlines the specific packages, configurations, and architectural choices made during the switch from Fedora GNOME to openSUSE Tumbleweed with Hyprland.

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
- **Zed:** Installed via the official binary script.

## 🖥️ Shell & Terminal Customization

- **Shell:** `zsh` set as the default login shell.
- **Prompt:** **Starship** (configured via dotfiles).
- **Zsh Plugins:** Syntax highlighting, autosuggestions, and completions (cloned from GitHub into `~/.zsh/`).
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

- **Browsers:** Chromium, Google Chrome (official repo), Brave (official repo), Zen (official binary).
- **Communication:** Slack.
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
- **Setup Modules:** `opensuse_setup/scripts/` (Sequence: 01_system, 02_packages, 03_tooling, 04_fonts, 05_terminal, 06_dotfiles)
- **Static Configurations:** `opensuse_setup/conf/` (fallbacks for kitty and vim, used if dotfiles are not set up)
- **Dotfiles Repository:** `~/dotfiles/` (cloned during phase 6; owns `~/.config/hypr`, `~/.config/waybar`, `~/.config/kitty`, etc. via symlinks)
- **Neovim Config:** `~/.config/nvim/` (independent repo — `engineervix/kickstart.nvim`, branch `custom`)
- **Zsh Config:** `~/.zshrc` (includes a robust set of Git and Docker aliases)

