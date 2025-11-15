#!/bin/bash

APP_CLASS=$1
SPECIAL_WORKSPACE_NAME="special:${APP_CLASS}"

# --- Safety Check ---
if [ -z "$APP_CLASS" ]; then
    echo "Usage: $0 <app_class>"
    exit 1
fi

# --- Main Logic ---
# Get the JSON data for all clients (windows)
CLIENTS=$(hyprctl clients -j)

# Find the workspace ID of our target application
APP_WORKSPACE_ID=$(echo "$CLIENTS" | jq -r ".[] | select(.class == \"$APP_CLASS\") | .workspace.id")

if [ -z "$APP_WORKSPACE_ID" ]; then
    kitty --class "$APP_CLASS" &

else
    ACTIVE_WORKSPACE_ID=$(hyprctl activeworkspace -j | jq -r ".id")

    if [ "$APP_WORKSPACE_ID" == "$ACTIVE_WORKSPACE_ID" ]; then
        hyprctl dispatch movetoworkspacesilent "$SPECIAL_WORKSPACE_NAME,class:^($APP_CLASS)$"

    else
        hyprctl dispatch movetoworkspace "$ACTIVE_WORKSPACE_ID,class:^($APP_CLASS)$"
        hyprctl dispatch focuswindow "class:^($APP_CLASS)$"
    fi
fi
