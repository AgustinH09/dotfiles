#!/bin/bash

# Check if a kitty instance with the class 'kitty-dropdown' exists
if hyprctl clients | grep -q "class: kitty-dropdown"; then
    hyprctl dispatch togglespecialworkspace special:dropdown
else
    kitty --class kitty-dropdown
fi
