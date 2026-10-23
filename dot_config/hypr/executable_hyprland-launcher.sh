#!/bin/bash

distro_id=$(grep '^ID=' /etc/os-release | cut -d'=' -f2)
distro_id=${distro_id:-fedora}
export HYPRLAND_DISTRO_CONFIG="${distro_id}.conf"

if command -v uwsm >/dev/null; then
  exec uwsm start -e -D Hyprland hyprland.desktop
fi

if command -v start-hyprland >/dev/null; then
  exec start-hyprland
fi

exec Hyprland
