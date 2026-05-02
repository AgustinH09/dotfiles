#!/bin/bash

SSID=$(/System/Library/PrivateFrameworks/Apple80211.framework/Resources/airport -I 2>/dev/null | awk -F': ' '/ SSID/{print $2}')

if [ -n "$SSID" ]; then
    sketchybar --set "$NAME" icon=󰖩 label="$SSID"
else
    sketchybar --set "$NAME" icon=󰖪 label="Off"
fi
