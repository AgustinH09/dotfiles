#!/bin/bash

# ──────────────────────────────────────────────────────────────────────────────
# Rainbow border animation for JankyBorders
# Mimics Hyprland RainbowBorders.sh — cycles random colors on the focused window
# ──────────────────────────────────────────────────────────────────────────────

# Kill any previous instance of this script
LOCKFILE="/tmp/rainbow_borders.pid"
if [ -f "$LOCKFILE" ]; then
    old_pid=$(cat "$LOCKFILE")
    if kill -0 "$old_pid" 2>/dev/null; then
        kill "$old_pid" 2>/dev/null
        wait "$old_pid" 2>/dev/null
    fi
fi
echo $$ > "$LOCKFILE"

cleanup() {
    rm -f "$LOCKFILE"
    exit 0
}
trap cleanup EXIT INT TERM

random_hex() {
    echo "0xff$(openssl rand -hex 3)"
}

INTERVAL=3

while true; do
    borders active_color="gradient(top_left=$(random_hex),top_right=$(random_hex),bottom_right=$(random_hex),bottom_left=$(random_hex))"
    sleep "$INTERVAL"
done
