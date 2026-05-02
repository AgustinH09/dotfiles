#!/bin/bash

CPU=$(top -l 1 -n 0 | awk '/CPU usage/{printf "%.0f", $3}')
sketchybar --set "$NAME" label="${CPU}%"
