#!/usr/bin/env bash
# gpu-screen-recorder is built from source (not in openSUSE repos) and links
# against Packman's ffmpeg libs. When Packman bumps libavfilter (e.g. 10.4→10.5),
# the binary breaks with "version LIBAVFILTER_X.Y_SUSE not found". Re-run this
# script after any Packman ffmpeg update to rebuild against the current libs.
set -euo pipefail

echo "==> Installing/updating ffmpeg dev libs from Packman..."
sudo zypper in -y --from packman \
    ffmpeg-7-libavcodec-devel \
    ffmpeg-7-libavformat-devel \
    ffmpeg-7-libavutil-devel \
    ffmpeg-7-libswresample-devel \
    ffmpeg-7-libavfilter-devel

GSR_BUILD_DIR="$(mktemp -d)"
trap 'rm -rf "$GSR_BUILD_DIR"' EXIT

echo "==> Cloning gpu-screen-recorder..."
git clone https://repo.dec05eba.com/gpu-screen-recorder "$GSR_BUILD_DIR/gpu-screen-recorder"

cd "$GSR_BUILD_DIR/gpu-screen-recorder"
LATEST_TAG=$(git describe --tags "$(git rev-list --tags --max-count=1)")
echo "==> Checking out $LATEST_TAG..."
git checkout "$LATEST_TAG"

echo "==> Building..."
meson setup --prefix=/usr --buildtype=release "$GSR_BUILD_DIR/build"
ninja -C "$GSR_BUILD_DIR/build"

echo "==> Installing..."
sudo ninja -C "$GSR_BUILD_DIR/build" install
sudo setcap cap_sys_admin+ep /usr/bin/gsr-kms-server

echo "==> Done. Verifying:"
gpu-screen-recorder --help | head -3
