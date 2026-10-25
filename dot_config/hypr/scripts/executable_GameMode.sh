#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Game Mode. Turning off all animations

notif="$HOME/.config/swaync/images/ja.png"
SCRIPTSDIR="$HOME/.config/hypr/scripts"


HYPRGAMEMODE=$(hyprctl -j getoption animations:enabled | jq -r '.bool')
if [ "$HYPRGAMEMODE" = true ] ; then
    hyprctl eval "hl.config({
        animations = { enabled = false },
        decoration = {
            shadow = { enabled = false },
            blur = { enabled = false },
            rounding = 0
        },
        general = { gaps_in = 0, gaps_out = 0, border_size = 1 }
    })"
    hyprctl eval "hl.window_rule({
        name = 'gamemode-opacity',
        match = { class = '.*' },
        opacity = 1.0
    })"
    swww kill
    notify-send -e -u low -i "$notif" " Gamemode:" " enabled"
    exit
else
    hyprctl reload
    if ! swww query >/dev/null 2>&1; then
        systemctl --user reset-failed swww-daemon.service 2>/dev/null || true
        systemd-run --user --quiet --collect --unit=swww-daemon \
            --property=Restart=on-failure swww-daemon --format xrgb
        for _ in {1..20}; do
            swww query >/dev/null 2>&1 && break
            sleep 0.1
        done
    fi

    wallpaper=$(readlink -f "$HOME/.config/rofi/.current_wallpaper" || true)
    if [ -f "$wallpaper" ]; then
        swww img "$wallpaper"
    fi

    notify-send -e -u normal -i "$notif" " Gamemode:" " disabled"
    exit
fi
