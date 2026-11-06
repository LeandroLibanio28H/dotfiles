#!/usr/bin/env bash

set -euo pipefail

if [[ "${EUID}" -eq 0 ]]; then
    echo "[!] Run this script as standard user. Sudo will be requested when needed."
    exit 1
fi

echo "[1/3] Updating Solus software repositories..."
sudo eopkg update-repo -y

echo "[2/3] Installing core Sway compositor and Wayland components..."
sudo eopkg install -y \
    sway \
    swaybg \
    swayidle \
    swaylock \
    waybar \
    wofi \
    xdg-desktop-portal-wlr \
    mako-notify \
    kitty \
    fastfetch \
    font-inter-ttf \
    font-jetbrainsmono-ttf \
    font-firacode-nerd \
    pavucontrol \
    gamemode \
    playerctl \
    grim \
    slurp \
    wl-clipboard \
    btop \
    ranger \
    nsxiv \
    mpv \
    ffmpegthumbnailer \
    poppler \
    imagemagick

echo "[3/3] Setting up user directories and environment..."
mkdir -p "${HOME}/Pictures/Screenshots"
mkdir -p "${HOME}/Pictures/Screenshots/windows"
mkdir -p "${HOME}/.local/bin"
mkdir -p "${HOME}/.config/gtk-3.0" "${HOME}/.config/gtk-4.0"

# Ranger wrapper to silence Python 3.14+ syntax warnings
cat << 'EOF' > "${HOME}/.local/bin/ranger"
#!/bin/sh
export PYTHONWARNINGS="ignore::SyntaxWarning"
exec /usr/bin/ranger "$@"
EOF
chmod +x "${HOME}/.local/bin/ranger"

if [[ -f "${HOME}/.config/ranger/scope.sh" ]]; then
    chmod +x "${HOME}/.config/ranger/scope.sh"
fi

echo "[✓] Installation completed successfully!"
