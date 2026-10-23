#!/usr/bin/env bash

set -euo pipefail

systemctl --user enable waybar.service >/dev/null

for _ in {1..100}; do
  if systemctl --user is-active --quiet graphical-session.target; then
    systemctl --user start waybar.service
    exit 0
  fi
  sleep 0.1
done

pgrep -x waybar >/dev/null && exit 0

systemctl --user reset-failed waybar-fallback.service 2>/dev/null || true
systemd-run --user --quiet --collect \
  --unit=waybar-fallback \
  --property=Restart=on-failure \
  /usr/bin/waybar
