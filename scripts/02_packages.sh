#!/usr/bin/env bash
# =============================================================================
# Script: 02_packages.sh
# Description: Installs Hyprland base, utilities, browsers, and specific apps.
# =============================================================================

log "--- [Phase 2: Package Installation] ---"

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
    cmake \
    expat \
    libexpat-devel \
    gdbm-devel \
    git-lfs \
    gstreamer-devel \
    gstreamer-plugins-base-devel \
    libffi-devel \
    libpcap-devel \
    postgresql-devel \
    postgresql-server-devel \
    libpqxx-devel \
    libyaml-devel \
    ncurses-devel \
    libopenssl-devel \
    libstdc++-devel \
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
    xz-devel

# Essential Tools
log "Installing utilities and applications..."
sudo zypper in -y \
    audacity \
    blueman \
    bat \
    brightnessctl \
    btop \
    cifs-utils \
    cliphist \
    d2 \
    duf \
    engrampa \
    easyeffects \
    eza \
    fastfetch \
    fastfetch-zsh-completion \
    fd \
    ffmpeg \
    fzf \
    gimp \
    imv \
    keychain \
    git \
    git-delta \
    gh \
    glab \
    gparted \
    gscan2pdf \
    htop \
    inkscape \
    jq \
    just \
    lazygit \
    libva-utils \
    libreoffice \
    libreoffice-gtk3 \
    meld \
    mpv \
    ncdu \
    okular \
    pandoc \
    rclone \
    ripgrep \
    screenkey \
    ShellCheck \
    socat \
    sqlitebrowser \
    tmux \
    tokei \
    transmission-gtk \
    xclip \
    xiphos \
    xournalpp \
    yq \
    yt-dlp \
    zathura \
    zathura-plugin-pdf-mupdf \
    zathura-zsh-completion \
    zoxide \
    zsh

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

# Configure git to use git-delta
# https://github.com/dandavison/delta
log "Configuring git with git-delta..."
git config --global core.pager delta
git config --global interactive.diffFilter 'delta --color-only'
git config --global delta.navigate true
git config --global delta.dark true  # or `delta.light true`, or omit for auto-detection
git config --global merge.conflictStyle zdiff3

# Docker
log "Installing Docker..."
sudo zypper in -y docker docker-compose
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"

# Enable PipeWire
log "Enabling PipeWire audio..."
# systemctl --user enable --now pipewire-pulse
# --user systemctl in a script running as root or early in setup can be tricky, so we wrap it:
sudo -u "$USER" systemctl --user enable --now pipewire-pulse 2>/dev/null || \
    info "PipeWire pulse will be enabled on next login"

# Bluetooth
log "Enabling Bluetooth..."
sudo systemctl enable --now bluetooth

log "Configuring BlueZ..."
sudo mkdir -p /etc/bluetooth
sudo tee /etc/bluetooth/main.conf > /dev/null << 'EOF'
[Policy]
AutoEnable=true
FastConnectable=true

[General]
DiscoverableTimeout=0
EOF

# Browsers
log "Installing Browsers..."
sudo zypper in -y chromium

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
    > "$HOME/.local/share/applications/bruno.desktop"

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
