#!/usr/bin/env bash
# LocalSend has no openSUSE package, so build it from source and install it for
# the current user (~/.local). Re-run to upgrade to the latest release tag.
# Not part of install.sh: first build downloads Flutter + compiles Rust (slow).
#
# Usage: scripts/localsend-build.sh            # latest release tag
#        LOCALSEND_REF=main scripts/localsend-build.sh
set -euo pipefail

SRC="${LOCALSEND_SRC:-$HOME/.local/src/localsend}"
PREFIX="$HOME/.local/opt/localsend"
BIN="$HOME/.local/bin"
APPS="$HOME/.local/share/applications"
ICONS="$HOME/.local/share/icons/hicolor/256x256/apps"
PORT=53317

export PATH="$HOME/fvm/bin:$HOME/.cargo/bin:$PATH"

echo "==> Checking build dependencies..."
sudo zypper in -y git curl clang cmake ninja pkgconf-pkg-config gtk3-devel libayatana-appindicator3-devel
command -v cargo >/dev/null || { echo "cargo missing: run install.sh (02_packages.sh installs rustup)" >&2; exit 1; }

if ! command -v fvm >/dev/null; then
  echo "==> Installing fvm..."
  curl -fsSL https://fvm.app/install.sh | bash
  hash -r
  command -v fvm >/dev/null || { echo "fvm not on PATH; add ~/fvm/bin and rerun" >&2; exit 1; }
fi

echo "==> Fetching LocalSend source..."
if [[ -d "$SRC/.git" ]]; then
  git -C "$SRC" fetch --tags --force origin
else
  mkdir -p "$(dirname "$SRC")"
  git clone https://github.com/localsend/localsend.git "$SRC"
fi
REF="${LOCALSEND_REF:-$(git -C "$SRC" tag --sort=-v:refname | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | head -1)}"
echo "==> Checking out $REF"
git -C "$SRC" checkout -q --force "$REF"
[[ "$REF" == "main" ]] && git -C "$SRC" pull -q --ff-only origin main

cd "$SRC"
fvm install
cd app
fvm flutter pub get
fvm dart run build_runner build
fvm dart run slang
fvm flutter build linux --release

echo "==> Installing to $PREFIX"
rm -rf "$PREFIX"
mkdir -p "$PREFIX" "$BIN" "$APPS" "$ICONS"
cp -r build/linux/x64/release/bundle/. "$PREFIX/"
# Wrapper: open the port while the app runs, close it on exit. firewall-cmd
# asks polkit for auth (GUI prompt), so no tty or sudo needed from the launcher.
# A second launch skips this: the app is single-instance and the first wrapper
# still owns the port.
rm -f "$BIN/localsend"
cat > "$BIN/localsend" <<WRAPPER
#!/usr/bin/env bash
if pgrep -x localsend_app >/dev/null; then exec "$PREFIX/localsend_app" "\$@"; fi
firewall-cmd -q --add-port=$PORT/tcp --add-port=$PORT/udp
trap 'firewall-cmd -q --remove-port=$PORT/tcp --remove-port=$PORT/udp' EXIT
trap exit INT TERM HUP
"$PREFIX/localsend_app" "\$@"
WRAPPER
chmod +x "$BIN/localsend"
cp assets/img/logo-256.png "$ICONS/localsend.png"
cat > "$APPS/localsend.desktop" <<DESKTOP
[Desktop Entry]
Name=LocalSend
Comment=Share files to nearby devices
Exec=$BIN/localsend
Icon=localsend
Type=Application
Categories=Network;FileTransfer;
DESKTOP
update-desktop-database "$APPS" 2>/dev/null || true

echo "Done ($REF). Run: localsend"
echo "Port $PORT opens while LocalSend runs and closes when it exits (polkit prompt on launch)."
