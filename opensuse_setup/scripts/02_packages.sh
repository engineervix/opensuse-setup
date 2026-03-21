#!/usr/bin/env bash
# =============================================================================
# Script: 02_packages.sh
# Description: Installs Hyprland base, utilities, browsers, and specific apps.
# =============================================================================

log "--- [Phase 2: Package Installation] ---"

# Core Hyprland Desktop Environment
log "Installing Hyprland ecosystem components..."
sudo zypper in -y \
    hyprland \
    hyprland-qtutils \
    waybar \
    rofi-wayland \
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
    wireplumber \
    pavucontrol \
    qt6-wayland \
    libqt5-qtwayland \
    NetworkManager-connection-editor \
    libnotify-tools \
    hyprland-devel

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
    gstreamer-devel \
    gstreamer-plugins-base-devel \
    libffi-devel \
    libpcap-devel \
    postgresql-devel \
    libyaml-devel \
    ncurses-devel \
    libopenssl-devel \
    mkcert \
    python3-devel \
    python3-pip \
    python3-virtualenv \
    python3-wheel \
    readline-devel \
    ruby-devel \
    sqlite3-devel \
    tk-devel \
    xz-devel \
    python3-pipx

# Essential Tools
log "Installing utilities and applications..."
sudo zypper in -y \
    audacity \
    bat \
    btop \
    cifs-utils \
    duf \
    easyeffects \
    eza \
    fd \
    ffmpeg \
    fzf \
    gimp \
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
    meld \
    ncdu \
    okular \
    pandoc \
    rclone \
    ripgrep \
    screenkey \
    ShellCheck \
    sqlitebrowser \
    tmux \
    tokei \
    transmission-gtk \
    vlc \
    xclip \
    xiphos \
    xournalpp \
    yq \
    yt-dlp \
    zoxide \
    zsh

# Docker
log "Installing Docker..."
sudo zypper in -y docker docker-compose
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"

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

# Spotify & Bruno (Native RPMs)
log "Installing Spotify and Bruno natively..."
# Spotify (via spotify-easyrpm)
sudo zypper rr home_megamaced 2>/dev/null || true
sudo zypper --gpg-auto-import-keys ar -cfp 90 https://download.opensuse.org/repositories/home:megamaced/openSUSE_Tumbleweed/home:megamaced.repo
sudo zypper ref
sudo zypper in -y spotify-easyrpm
info "To finish Spotify installation, run 'spotify-easyrpm' after the setup is complete."

# Bruno API Client
log "Downloading and installing latest Bruno RPM..."
BRUNO_LATEST_VERSION=$(curl -s https://api.github.com/repos/usebruno/bruno/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
BRUNO_DOWNLOAD_VERSION=${BRUNO_LATEST_VERSION#v}
wget -qO /tmp/bruno.rpm "https://github.com/usebruno/bruno/releases/download/$BRUNO_LATEST_VERSION/bruno_${BRUNO_DOWNLOAD_VERSION}_x86_64_linux.rpm"
sudo zypper in -y /tmp/bruno.rpm
rm -f /tmp/bruno.rpm

# Communication tools (Slack, Zoom)
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

install_zoom() {
    log "Installing Zoom via official RPM..."
    local rpm_url="https://zoom.us/client/latest/zoom_openSUSE_x86_64.rpm"
    local temp_rpm="/tmp/zoom_desktop.rpm"
    
    info "Downloading Zoom RPM package..."
    if curl -sL -o "$temp_rpm" "$rpm_url"; then
        sudo zypper in --allow-unsigned-rpm -y "$temp_rpm"
        rm -f "$temp_rpm"
        log "Zoom installed successfully"
    else
        error "Failed to download Zoom"
    fi
}
install_zoom
