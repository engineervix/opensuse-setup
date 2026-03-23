#!/usr/bin/env bash
# =============================================================================
# Script: 01_system.sh
# Description: Handles base system configuration, repository management,
#              DNS setup, and system updates.
# =============================================================================

log "--- [Phase 1: System Base Configuration] ---"

# Remove any stale repos from previous runs before refreshing
log "Cleaning up any stale repositories from previous runs..."
sudo zypper rr brave-browser 2>/dev/null || true
sudo zypper rr google-chrome 2>/dev/null || true
sudo zypper rr packman 2>/dev/null || true
sudo zypper rr packman-essentials 2>/dev/null || true
sudo zypper rr home_megamaced 2>/dev/null || true

# Refresh repositories and trust keys early
log "Refreshing repositories and trusting GPG keys..."
sudo zypper --gpg-auto-import-keys ref

# Set hostname
log "Let's set up a new hostname"
read -rp 'hostname: ' myhostname
sudo hostnamectl set-hostname "$myhostname"

# Configure Git identity
log "Configuring Git identity..."
read -rp 'Git full name: ' git_name
read -rp 'Git email: ' git_email
git config --global user.name "$git_name"
git config --global user.email "$git_email"

# Configure DNS over TLS for better privacy
setup_dns() {
    log "Setting up secure DNS with Cloudflare DNS over TLS..."
    sudo zypper in -y systemd-resolved
    sudo mkdir -p '/etc/systemd/resolved.conf.d'
    sudo tee '/etc/systemd/resolved.conf.d/99-dns-over-tls.conf' > /dev/null << 'EOF'
[Resolve]
DNS=1.1.1.2#security.cloudflare-dns.com 1.0.0.2#security.cloudflare-dns.com 2606:4700:4700::1112#security.cloudflare-dns.com 2606:4700:4700::1002#security.cloudflare-dns.com
DNSOverTLS=yes
EOF
    sudo systemctl enable --now systemd-resolved

    # Point resolv.conf at the stub resolver so applications actually use systemd-resolved
    sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

    # Tell NetworkManager to hand off DNS to systemd-resolved
    sudo mkdir -p /etc/NetworkManager/conf.d
    sudo tee /etc/NetworkManager/conf.d/dns.conf > /dev/null << 'EOF'
[main]
dns=systemd-resolved
EOF
    sudo systemctl reload NetworkManager 2>/dev/null || true

    log "DNS over TLS configured with Cloudflare's security-focused DNS servers"
}
setup_dns

# Optimize zypper
log "Optimizing zypper configuration for faster downloads..."
sudo mkdir -p /etc/zypp
if [ ! -f /etc/zypp/zypp.conf ] || ! grep -q "download.max_concurrent_connections" /etc/zypp/zypp.conf; then
    echo "download.max_concurrent_connections = 10" | sudo tee -a /etc/zypp/zypp.conf
fi

# System update
log "Updating system packages via zypper dup (distribution upgrade)..."
sudo zypper dup -y

# Setup Packman & OPI
log "Installing OPI (OBS Package Installer)..."
sudo zypper in -y opi

log "Adding Packman Essentials repository (recommended to prevent update conflicts)..."
sudo zypper --gpg-auto-import-keys ar -cfp 90 https://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Tumbleweed/Essentials/ packman-essentials || true
sudo zypper ref
