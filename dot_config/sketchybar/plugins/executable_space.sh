#!/bin/bash

ACTIVE=$(yabai -m query --spaces --space 2>/dev/null | jq '.index // 1')
[ -z "$ACTIVE" ] && ACTIVE=1

# Carousel of 5 with active centered: clamp start to [1, 6]
START=$((ACTIVE - 2))
[ "$START" -lt 1 ] && START=1
[ "$START" -gt 6 ] && START=6
END=$((START + 4))

for sid in $(seq 1 10); do
    if [ "$sid" -ge "$START" ] && [ "$sid" -le "$END" ]; then
        sketchybar --set space.$sid drawing=on
        if [ "$sid" -eq "$ACTIVE" ]; then
            sketchybar --animate tanh 12 --set space.$sid \
                icon.color=0xfff38ba8 \
                background.color=0x60313244
        else
            sketchybar --animate tanh 12 --set space.$sid \
                icon.color=0xff585b70 \
                background.color=0x00000000
        fi
    else
        sketchybar --set space.$sid drawing=off
    fi
done
