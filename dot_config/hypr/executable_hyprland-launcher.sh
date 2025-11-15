#!/bin/bash

distro_id=$(grep '^ID=' /etc/os-release | cut -d'=' -f2)
distro_id=${distro_id:-fedora}
export HYPRLAND_DISTRO_CONFIG="${distro_id}.conf"

exec Hyprland
