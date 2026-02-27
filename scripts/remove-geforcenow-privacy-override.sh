#!/bin/bash
# Remove GeForce NOW AUR package, custom desktop entry override,
# and xpadneo-dkms with its system configuration.
# Run this before using Omarchy's built-in installers instead.

set -e

# GeForce NOW
DESKTOP_FILE="$HOME/.local/share/applications/com.github.hmlendea.geforcenow-electron.desktop"

if pacman -Qi geforcenow-electron &>/dev/null; then
    yay -Rs --noconfirm geforcenow-electron
    echo "Uninstalled geforcenow-electron."
else
    echo "geforcenow-electron is not installed, skipping."
fi

if [ -f "$DESKTOP_FILE" ]; then
    rm "$DESKTOP_FILE"
    echo "Removed desktop entry override: $DESKTOP_FILE"
else
    echo "No desktop entry override found, skipping."
fi

# Xbox controller driver
if pacman -Qi xpadneo-dkms &>/dev/null; then
    yay -Rs --noconfirm xpadneo-dkms
    echo "Uninstalled xpadneo-dkms."
else
    echo "xpadneo-dkms is not installed, skipping."
fi

sudo rm -f /etc/modprobe.d/blacklist-xpad.conf /etc/modules-load.d/xpadneo.conf
echo "Removed xpadneo system configuration files."
