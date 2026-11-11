# openSUSE Tumbleweed + Hyprland: Setup Details

This document outlines the specific packages, configurations, and architectural choices made during the switch from Fedora GNOME to openSUSE Tumbleweed with Hyprland.

## 🖥️ Graphical Environment (The "Hyprland Ecosystem")

Unlike GNOME's "all-in-one" approach, this setup uses modular Wayland components:

| Component         | Choice                  | Description                                                   |
| :---------------- | :---------------------- | :------------------------------------------------------------ |
| **Compositor**    | `hyprland`              | Dynamic tiling Wayland compositor. |
| **Qt Utils**      | `hyprland-qtutils`      | Suppresses missing asset warnings when disabling standard zypper recommendations. |
| **Display Mgr**   | `sddm-qt6`              | Wayland-native display manager, replacing legacy sddm (Qt5).  |
| **Status Bar**    | `waybar`                | Highly customizable GTK bar.                                  |
| **App Launcher**  | `rofi`                  | Application runner and menu system (native Wayland support since 2025). |
| **Logout Menu**   | `wlogout`               | Highly customizable Wayland logout menu.                      |
| **Terminal**      | `kitty`                 | GPU-accelerated terminal. Static config managed in `conf/`. |
| **Night Light**   | `hyprsunset`            | Native Wayland blue-light filter.                             |

## 🛠️ Development Tooling

The setup translates Fedora's `dnf groups` into openSUSE `patterns` and installs specific version managers.

- **Build Essentials:** Installed via `devel_basis` and `devel_C_C++` patterns (includes `gcc`, `make`, `cmake`, `gdb`).
- **Node.js:** Managed by **Vite+** (`vp`), which replaced the unmaintained Volta. It downloads Node.js (latest LTS by default) and the package managers (npm, pnpm, yarn, bun) on first use, and pins each global CLI to the Node LTS it was installed with. Includes global installs (`vp install -g --node lts`) of:
  - `@apollo/rover`, `@marp-team/marp-cli`, `@vtsls/language-server`
  - `ccusage`, `commit-and-tag-version`, `doctoc`
  - `eslint`, `eslint-config-prettier`, `stylelint`
  - `gitlab-ci-local`, `heroku` (the Heroku CLI, see Cloud below), `hunkdiff`, `jscpd`, `pa11y`
  - `mdpdf`, `prettier`, `svgo`, `serve`
  - `neovim` (for node host support), `pyright`, `typescript`.
  - `pnpm` comes from Vite+'s own shim, so it is not installed as a global package.
  - Pin a project's Node with `vp env pin <version>` (see the [`vp env` guide](https://viteplus.dev/guide/env)).
- **Python:** Managed by **pyenv**. Includes **Poetry** (with Zsh completions) and `virtualenvwrapper`.
- **Go:** Installed via Zypper. Includes `gopls` and `golangci-lint`.
- **Rust:** Managed via **rustup**.
- **Containers:** **rootless Docker** and **Docker Compose** (see [Rootless Docker](#rootless-docker)).
- **Cloud:** **AWS CLI v2** and **Heroku CLI**.

### Rootless Docker

The Docker daemon runs as your user (`systemctl --user status docker`), so there is no `docker` group and no root-equivalent socket. The CLI uses the `rootless` context, and the socket is `$XDG_RUNTIME_DIR/docker.sock`. What differs from a rootful daemon:

- **Bind mounts and uids.** Container uid 0 is your user. Other container uids map into your subordinate range (`/etc/subuid`): uid 1000 in a container is typically uid 100999 on the host, so a non-root container user may fail to write to a bind mount you own. Either run that service as `user: root` (which is you on the host), or give the mapped uid an ACL: `setfacl -R -m u:100999:rwx <dir>`.
- **SELinux.** Containers need no `:z` or `chcon` on bind mounts. Leave `selinux-enabled` off in the rootless daemon's config: turning it on breaks `docker exec`.
- **Ports.** `/etc/sysctl.d/90-rootless-ports.conf` lets unprivileged processes bind ports 80–1023, so a local reverse proxy can use `:80`.
- **Dev servers on the host.** Host loopback is blocked, and `host-gateway` resolves inside the daemon's own network namespace, so neither reaches the host. `host-gateway-ip.service` adds `10.254.254.254` to `lo` instead. Map `host.docker.internal` to it with `extra_hosts`, and make the dev server listen on `0.0.0.0`, not only `127.0.0.1`.
- **Boot.** The `ip_tables` modules load at boot from `/etc/modules-load.d/rootless-docker.conf`. The daemon starts when you log in; `loginctl enable-linger` makes it start at boot instead.
- **Resource limits.** Only cgroup controllers delegated to your user apply, so `cpus:` and memory limits may be ignored with a warning.
- **Old data.** Images and volumes from a previous rootful daemon are not visible to the rootless one. Dump databases before switching.

## 📝 Modern Text Editors

- **Neovim:** Replaced legacy Vim setup.
  - **Config:** `engineervix/kickstart.nvim` (branch: `custom`).
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
  - `neofetch` ➔ `fastfetch`
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
  - [presenterm](https://github.com/mfontanini/presenterm) for terminal-based markdown presentations (binary installed to `~/bin/`).
  - Xiphos (Bible study tool) — from the [Education OBS repo](https://download.opensuse.org/repositories/Education/openSUSE_Tumbleweed/).
- **System & Utility:**
  - Avahi (`avahi` + `avahi-utils`) for mDNS/DNS-SD — enables `.local` hostname resolution on the local network (e.g. `homeassistant.local`). Requires the `mdns` firewall service to be open, which the script handles. If resolution still fails, set `allow-interfaces=<iface>` in `/etc/avahi/avahi-daemon.conf` to prevent avahi binding to Docker/VPN interfaces.
  - GParted for partition management.
  - Transmission-GTK for BitTorrent.
  - Screenkey for screencasts.
  - DB Browser for SQLite.
  - `gtypist` for touch-typing practice in the terminal.
  - `htop`, `btop` for live monitoring; `atop` + `atop-daemon` for historical per-process CPU/mem/disk logging (`atop.service` enabled, logs to `/var/log/atop` every 10 min, 28-day retention — see [atoptool/atop](https://github.com/Atoptool/atop)).
- **API Client:** Bruno (Native RPM from official GitHub).

## 📂 Key File Locations
- **Main Entrypoint:** `install.sh`
- **Setup Modules:** `scripts/` (Sequence: 01_system, 02_packages, 03_tooling, 04_fonts, 05_terminal, 06_dotfiles)
- **Static Configurations:** `conf/` (fallbacks for kitty and vim, used if dotfiles are not set up)
- **Dotfiles Repository:** `~/dotfiles/` (cloned during phase 6; owns `~/.config/hypr`, `~/.config/waybar`, `~/.config/kitty`, etc. via symlinks)
- **Neovim Config:** `~/.config/nvim/` (independent repo — `engineervix/kickstart.nvim`, branch `custom`)
- **Zsh Config:** `~/.zshrc` (includes a robust set of Git and Docker aliases)
