#!/bin/bash

if [ "$SENDER" = "volume_change" ]; then
    VOLUME="$INFO"
else
    VOLUME=$(osascript -e 'output volume of (get volume settings)')
fi

if [ "$VOLUME" -eq 0 ]; then
    ICON=󰝟
elif [ "$VOLUME" -lt 33 ]; then
    ICON=󰕿
elif [ "$VOLUME" -lt 66 ]; then
    ICON=󰖀
else
    ICON=󰕾
fi

sketchybar --set "$NAME" icon="$ICON" label="${VOLUME}%"
