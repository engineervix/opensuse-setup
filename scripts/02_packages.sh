#!/usr/bin/env bash
# =============================================================================
# Script: 02_packages.sh
# Description: Installs Hyprland base, utilities, browsers, and specific apps.
# =============================================================================

log "--- [Phase 2: Package Installation] ---"

# Rust. Installed here (rather than in 03_tooling.sh, which normally owns dev
# tooling) because the SwayOSD and Satty builds below need it and this phase
# runs first; 03_tooling.sh reuses this same install.
if ! command -v rustup &>/dev/null; then
  log "Installing rustup..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi
source "$HOME/.cargo/env"

# Core Hyprland Desktop Environment
log "Configuring Packman repository for multimedia codecs..."
sudo zypper ar -cfp 90 https://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Tumbleweed/ packman || true
sudo zypper --gpg-auto-import-keys ref
sudo zypper dup --from packman --allow-vendor-change -y

log "Installing Hyprland ecosystem components..."
sudo zypper in -y \
  hyprland \
  hyprland-qtutils \
  waybar \
  rofi \
  kitty \
  dunst \
  hyprpaper \
  hypridle \
  hyprlock \
  hyprsunset \
  wlogout \
  polkit-kde-agent-6 \
  wl-clipboard \
  thunar \
  thunar-archive-plugin \
  xdg-desktop-portal-hyprland \
  sddm-qt6 \
  grim \
  slurp \
  pipewire \
  pipewire-pulseaudio \
  pipewire-aptx \
  wireplumber \
  pavucontrol \
  qt6-wayland \
  libqt5-qtwayland \
  NetworkManager-connection-editor \
  NetworkManager-applet \
  libnotify-tools \
  hyprland-devel \
  adwaita-qt6 \
  papirus-icon-theme \
  qt6-multimedia-imports \
  qt6ct

# Development Patterns
log "Installing core development patterns and dependencies..."
sudo zypper addlock subversion git-svn || true
sudo zypper in -y --no-recommends -t pattern devel_basis devel_C_C++

log "Installing core development packages..."
sudo zypper in -y \
  libbz2-devel \
  Catch2-devel \
  cmake \
  expat \
  libexpat-devel \
  gdbm-devel \
  gcovr \
  git-lfs \
  gstreamer-devel \
  gstreamer-plugins-base-devel \
  libffi-devel \
  libpcap-devel \
  libtag-devel \
  postgresql-devel \
  postgresql-server-devel \
  libpqxx-devel \
  libyaml-devel \
  ncurses-devel \
  libopenssl-devel \
  libstdc++-devel \
  libc++-devel \
  mkcert \
  patchelf \
  python3-devel \
  python3-pip \
  python3-pipx \
  python3-virtualenv \
  python3-wheel \
  readline-devel \
  ruby-devel \
  sqlite3-devel \
  tk-devel \
  wxGTK3-3_2-devel \
  xz-devel

# Essential Tools
log "Installing utilities and applications..."
sudo zypper in -y \
  atop \
  atop-daemon \
  audacity \
  avahi \
  avahi-utils \
  blueman \
  bat \
  bc \
  brightnessctl \
  btop \
  cifs-utils \
  cliphist \
  d2 \
  difftastic \
  duf \
  engrampa \
  easyeffects \
  eza \
  fastfetch \
  fastfetch-zsh-completion \
  fd \
  ffmpeg \
  fzf \
  v4l-utils \
  gimp \
  glow \
  imv \
  keychain \
  git \
  git-delta \
  gh \
  glab \
  gparted \
  gscan2pdf \
  htop \
  hyperfine \
  inkscape \
  jq \
  just \
  lazygit \
  libva-utils \
  libreoffice \
  libreoffice-gtk3 \
  meld \
  mercurial \
  mpv \
  ncdu \
  nmap \
  okular \
  pandoc \
  pinentry-qt6 \
  poppler-tools \
  rclone \
  resvg \
  ripgrep \
  screenkey \
  ShellCheck \
  socat \
  socat-extra \
  sqlite3 \
  sqlitebrowser \
  taskwarrior \
  tealdeer \
  tig \
  tig-zsh-completion \
  timewarrior \
  tmux \
  tokei \
  transmission-gtk \
  trivy \
  w3m \
  xclip \
  xiphos \
  xournalpp \
  yazi \
  yazi-zsh-completion \
  yq \
  yt-dlp \
  zathura \
  zathura-plugin-pdf-poppler \
  zathura-zsh-completion \
  zoxide \
  zsh

# PDF backend (2026-06-01): use zathura-plugin-pdf-poppler, NOT
# zathura-plugin-pdf-mupdf. The mupdf plugin (2026.05.10) broke on Tumbleweed
# after the mupdf 1.27.2 update — it links mupdf statically but not mupdf's
# system codec libs (libjpeg-turbo, openjpeg, jbig2dec, brotli), so it fails to
# load with `undefined symbol: jpeg_resync_to_restart` (~284 unresolved
# symbols). poppler links libpoppler-glib dynamically and loads clean. The two
# plugins conflict (both provide application/pdf), so only one may be installed.
# Bug report: docs/zathura-mupdf-bug.md. Revert to mupdf once it is rebuilt
# against system codec libs.

# ffmpeg libs: OSS builds lack HEVC/H.264 (patent-encumbered). Installing ffmpeg
# from the essential tools block above pulls in OSS libavcodec62 and siblings.
# Explicitly switch them to Packman builds after the fact.
log "Switching ffmpeg libs to Packman builds (HEVC/codec support)..."
sudo zypper in -y --from packman \
  libavcodec62 \
  libavdevice62 \
  libavfilter11 \
  libavformat62 \
  libavutil60 \
  libswresample6 \
  libswscale9

# gpu-screen-recorder (build from source)
# The openSUSE package is patched to hide H264/HEVC support, so we build from
# upstream source against Packman's ffmpeg-7 to get proper codec detection via VA-API.
log "Installing gpu-screen-recorder build dependencies..."
sudo zypper in -y --from packman \
  ffmpeg-7-libavcodec-devel \
  ffmpeg-7-libavformat-devel \
  ffmpeg-7-libavutil-devel \
  ffmpeg-7-libswresample-devel \
  ffmpeg-7-libavfilter-devel

sudo zypper in -y \
  meson \
  libXcomposite-devel \
  libXrandr-devel \
  libXfixes-devel \
  libXdamage-devel \
  libva-devel \
  libcap-devel \
  libcap-progs \
  vulkan-headers \
  pipewire-devel \
  libpulse-devel

log "Building and installing gpu-screen-recorder from source..."
GSR_REPO="https://repo.dec05eba.com/gpu-screen-recorder"
GSR_BUILD_DIR="$(mktemp -d)"
git clone "$GSR_REPO" "$GSR_BUILD_DIR/gpu-screen-recorder"
(
  cd "$GSR_BUILD_DIR/gpu-screen-recorder" || exit
  LATEST_TAG=$(git describe --tags "$(git rev-list --tags --max-count=1)")
  git checkout "$LATEST_TAG"
  meson setup --prefix=/usr --buildtype=release "$GSR_BUILD_DIR/build"
  ninja -C "$GSR_BUILD_DIR/build"
  sudo ninja -C "$GSR_BUILD_DIR/build" install
  sudo setcap cap_sys_admin+ep /usr/bin/gsr-kms-server
)
rm -rf "$GSR_BUILD_DIR"

# SwayOSD (build from source - not in openSUSE repos)
# Requires nightly Rust; toolchain is installed temporarily and removed after build.
log "Installing SwayOSD build dependencies..."
sudo zypper in -y \
  sassc \
  libadwaita-devel \
  gtk4-layer-shell-devel \
  libgtk4-layer-shell0 \
  libevdev-devel

log "Installing nightly Rust toolchain (required by SwayOSD)..."
rustup toolchain install nightly

log "Building and installing SwayOSD from source..."
SWAYOSD_BUILD_DIR="$(mktemp -d)"
git clone https://github.com/ErikReider/SwayOSD "$SWAYOSD_BUILD_DIR/swayosd"
(
  cd "$SWAYOSD_BUILD_DIR/swayosd" || exit
  LATEST_TAG=$(git describe --tags "$(git rev-list --tags --max-count=1)")
  git checkout "$LATEST_TAG"
  PATH="$HOME/.cargo/bin:$PATH" meson setup --prefix=/usr --buildtype=release "$SWAYOSD_BUILD_DIR/build"
  ninja -C "$SWAYOSD_BUILD_DIR/build"
  sudo env PATH="$PATH" ninja -C "$SWAYOSD_BUILD_DIR/build" install
  sudo usermod -aG video "$USER"
)
rm -rf "$SWAYOSD_BUILD_DIR"

log "Removing nightly Rust toolchain..."
rustup toolchain uninstall nightly

# Satty (screenshot annotation - not in openSUSE repos)
# Needs if-let match guards in a match arm, stabilized in Rust 1.95; rustup's
# "stable" channel can lag behind, so pin the toolchain for this build only.
log "Installing Satty build dependencies..."
sudo zypper in -y \
  gtk4-devel \
  fontconfig-devel \
  libepoxy-devel

log "Installing Rust 1.95.0 toolchain (required by Satty)..."
rustup toolchain install 1.95.0

log "Building and installing Satty..."
cargo +1.95.0 install satty --locked

# Configure git to use git-delta
# https://github.com/dandavison/delta
log "Configuring git with git-delta..."
git config --global core.pager delta
git config --global interactive.diffFilter 'delta --color-only'
git config --global delta.navigate true
git config --global delta.dark true # or `delta.light true`, or omit for auto-detection
git config --global delta.side-by-side true
git config --global merge.conflictStyle zdiff3

# difftastic as an opt-in difftool (invoked via `git difftool`) — does not
# touch core.pager/pager.diff above, so delta/diffnav stay the defaults.
git config --global diff.tool difftastic
# shellcheck disable=SC2016 # $LOCAL/$REMOTE must stay unexpanded here; git expands them when it runs the tool
git config --global difftool.difftastic.cmd 'difft "$LOCAL" "$REMOTE"'

# hunk (https://hunk.dev) as opt-in aliases — same reasoning as difftastic
# above, so delta/diffnav keep core.pager/pager.diff. Use `git hdiff`/`git
# hshow` when you want hunk's review UI (sidebar, inline Claude Code notes)
# instead of the plain pager.
# shellcheck disable=SC2016 # kept unexpanded; passed through to `-c` as a literal git config value
git config --global alias.hdiff '-c core.pager="hunk pager" diff'
# shellcheck disable=SC2016 # kept unexpanded; passed through to `-c` as a literal git config value
git config --global alias.hshow '-c core.pager="hunk pager" show'

# GitHub CLI extensions
log "Installing GitHub CLI extensions..."
for ext in dlvhdr/gh-dash agynio/gh-pr-review; do
  if ! gh extension list 2>/dev/null | grep -q "$(basename "$ext")"; then
    gh extension install "$ext"
  fi
done

# Docker
log "Installing Docker..."
sudo zypper in -y docker docker-compose
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"

# Shared network for the local dev reverse proxy (see dotfiles: .config/traefik/)
docker network create traefik 2>/dev/null || true

# Enable PipeWire
log "Enabling PipeWire audio..."
# systemctl --user enable --now pipewire-pulse
# --user systemctl in a script running as root or early in setup can be tricky, so we wrap it:
sudo -u "$USER" systemctl --user enable --now pipewire-pulse 2>/dev/null ||
  info "PipeWire pulse will be enabled on next login"

# Bluetooth
log "Enabling Bluetooth..."
sudo systemctl enable --now bluetooth

log "Configuring BlueZ..."
sudo mkdir -p /etc/bluetooth
sudo tee /etc/bluetooth/main.conf >/dev/null <<'EOF'
[Policy]
AutoEnable=true
FastConnectable=true

[General]
DiscoverableTimeout=0
EOF

# Avahi (mDNS/DNS-SD)
log "Enabling Avahi mDNS daemon..."
sudo systemctl enable --now avahi-daemon

log "Opening mDNS in firewall (required for .local hostname resolution)..."
sudo firewall-cmd --add-service=mdns --permanent
sudo firewall-cmd --reload
# NOTE: If .local hostnames still don't resolve, avahi may be binding to the wrong
# interface (e.g. Docker bridges, Tailscale). Fix: add allow-interfaces=<iface>
# under [server] in /etc/avahi/avahi-daemon.conf, then restart avahi-daemon.
# Find your interface name with: ip link show

# atop (historical per-process CPU/mem/disk logging: https://github.com/Atoptool/atop)
# atop-daemon subpackage ships the atop.service unit; the base atop package
# only has the binaries.
# Default config logs to /var/log/atop every 10 min, keeps 28 days.
log "Enabling atop persistent logging..."
sudo systemctl enable --now atop.service

# ActivityWatch (via the awatcher bundle: https://github.com/2e3s/awatcher)
#
# No openSUSE/Packman package exists, so this installs the upstream release
# binary directly. We use the "bundle" build (self-contained aw-server-rust +
# watcher + tray, one binary) rather than the official aw-qt/AppImage
# distribution — the official Linux AppImage/Flatpak can't query Wayland
# activity at all, so on Hyprland (Wayland-only) its bundled
# aw-watcher-window/aw-watcher-afk never see real window or idle data.
# awatcher supports Hyprland directly via the wlr-foreign-toplevel-management
# and ext-idle-notify-v1 Wayland protocols — verified working on this setup.
log "Installing ActivityWatch (awatcher bundle)..."
AW_BIN_DIR="$HOME/.local/bin"
AW_BIN_PATH="$AW_BIN_DIR/awatcher"
AW_VERSION_MARKER="$AW_BIN_DIR/.awatcher.version"
AW_UNIT_DIR="$HOME/.config/systemd/user"
AW_UNIT_PATH="$AW_UNIT_DIR/awatcher.service"

AW_VERSION=$(curl -s https://api.github.com/repos/2e3s/awatcher/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
if [[ -x "$AW_BIN_PATH" ]] && [[ "$(cat "$AW_VERSION_MARKER" 2>/dev/null || true)" == "$AW_VERSION" ]]; then
  info "awatcher $AW_VERSION already installed, skipping download."
else
  mkdir -p "$AW_BIN_DIR"
  AW_EXTRACT_DIR="$(mktemp -d)"
  curl -fL -o "$AW_EXTRACT_DIR/awatcher-bundle.zip" \
    "https://github.com/2e3s/awatcher/releases/download/${AW_VERSION}/awatcher-bundle.zip"
  unzip -q "$AW_EXTRACT_DIR/awatcher-bundle.zip" -d "$AW_EXTRACT_DIR"
  install -m 755 "$AW_EXTRACT_DIR/awatcher" "$AW_BIN_PATH"
  echo "$AW_VERSION" >"$AW_VERSION_MARKER"
  rm -rf "$AW_EXTRACT_DIR"
fi

log "Configuring awatcher app-id filters..."
AW_CONFIG_DIR="$HOME/.config/awatcher"
AW_CONFIG_PATH="$AW_CONFIG_DIR/config.toml"
mkdir -p "$AW_CONFIG_DIR"
touch "$AW_CONFIG_PATH"
# awatcher's window watcher reports Google Chrome's app-id as bare
# "google-chrome", which isn't in aw-webui's hardcoded browser_appnames.chrome
# list (it has "google-chrome-stable" and "Google-chrome" but not this exact
# string) — so the web UI's Browser view domain/URL breakdown silently comes
# up empty even though the browser extension is capturing data correctly.
# Rename the app-id at the source to a variant aw-webui recognizes.
if ! grep -q 'match-app-id = "google-chrome"' "$AW_CONFIG_PATH"; then
  cat >>"$AW_CONFIG_PATH" <<'EOF'

[[awatcher.filters]]
match-app-id = "google-chrome"
replace-app-id = "Google-chrome"
EOF
fi

log "Installing awatcher systemd --user unit..."
mkdir -p "$AW_UNIT_DIR"
cat >"$AW_UNIT_PATH" <<EOF
[Unit]
Description=ActivityWatch (awatcher bundle)
After=graphical-session.target

[Service]
Type=simple
TimeoutStartSec=120
ExecStartPre=/bin/sleep 5
ExecStart=$AW_BIN_PATH
Restart=always
RestartSec=5
RestartSteps=2
RestartMaxDelaySec=15

[Install]
WantedBy=graphical-session.target
EOF

# This repo's Hyprland config doesn't activate graphical-session.target (no
# uwsm, no hyprland-session.target shim), so the [Install] section above is
# inert here — `systemctl --user enable` would never actually get pulled in.
# Autostart instead comes from dotfiles: autostart.lua runs
# `systemctl --user start awatcher.service` directly on hyprland.start.
sudo -u "$USER" systemctl --user daemon-reload 2>/dev/null ||
  info "Run 'systemctl --user daemon-reload' manually on next login."
sudo -u "$USER" systemctl --user start awatcher.service 2>/dev/null ||
  info "awatcher.service will start on next login via autostart.lua."

# Browsers
log "Installing Browsers..."

# ungoogled-chromium (replaces stock chromium; same binary/.desktop names,
# so no changes needed elsewhere for the chromium alias or menu entry)
sudo zypper rr network:chromium 2>/dev/null || true
sudo zypper ar -f https://download.opensuse.org/repositories/network:chromium/openSUSE_Tumbleweed/network:chromium.repo
sudo zypper ref
sudo zypper in -y ungoogled-chromium

# Google Chrome
sudo rpm --import https://dl-ssl.google.com/linux/linux_signing_key.pub
sudo zypper rr google-chrome 2>/dev/null || true
sudo zypper --gpg-auto-import-keys ar -f http://dl.google.com/linux/chrome/rpm/stable/x86_64 google-chrome
sudo zypper ref
sudo zypper in -y google-chrome-stable

# Brave
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
sudo zypper rr brave-browser 2>/dev/null || true
sudo zypper --gpg-auto-import-keys ar -f https://brave-browser-rpm-release.s3.brave.com/x86_64 brave-browser
sudo zypper ref
sudo zypper in -y brave-browser

# Playwright (headless browser testing)
# All other shared-lib deps (atk, cairo, nss, cups-libs, gtk3, gbm, X11 libs,
# pango) are already pulled in by the browser installs above. icu and flite
# are not, and `playwright install-deps` fails on Tumbleweed anyway (it
# shells out to apt-get, which doesn't exist here) — so install them directly.
sudo zypper in -y icu flite

# Spotify (via spotify-easyrpm)
log "Installing Spotify..."
sudo zypper in -y spotify-easyrpm
info "To finish Spotify installation, run 'spotify-easyrpm' after the setup is complete."

# Bruno API Client
log "Downloading and installing latest Bruno RPM..."
BRUNO_LATEST_VERSION=$(curl -s https://api.github.com/repos/usebruno/bruno/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
BRUNO_DOWNLOAD_VERSION=${BRUNO_LATEST_VERSION#v}
wget -qO /tmp/bruno.rpm "https://github.com/usebruno/bruno/releases/download/$BRUNO_LATEST_VERSION/bruno_${BRUNO_DOWNLOAD_VERSION}_x86_64_linux.rpm"
sudo zypper in -y /tmp/bruno.rpm
rm -f /tmp/bruno.rpm

# Fix Bruno for Wayland
log "Patching Bruno desktop entry for Wayland..."
mkdir -p "$HOME/.local/share/applications"
sed 's|Exec=/opt/Bruno/bruno %U|Exec=/opt/Bruno/bruno --ozone-platform=wayland %U|' \
  /usr/share/applications/bruno.desktop \
  >"$HOME/.local/share/applications/bruno.desktop"

# Communication tools
install_slack() {
  log "Starting Slack installation..."
  local download_url
  download_url=$(curl -sL "https://slack.com/downloads/instructions/linux?ddl=1&build=rpm" | grep -o 'https://downloads.slack-edge.com[^"]*\.rpm' | head -1)
  if [ -z "$download_url" ]; then
    error "Could not find Slack download URL"
    return 1
  fi
  info "Downloading Slack RPM package..."
  if curl -L -o "/tmp/slack.rpm" "$download_url"; then
    sudo zypper in --allow-unsigned-rpm -y /tmp/slack.rpm
    rm -f /tmp/slack.rpm
    log "Slack installed successfully"
  fi
}
install_slack
