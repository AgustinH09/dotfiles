#!/bin/bash

USED=$(memory_pressure 2>/dev/null | awk '/percentage/{gsub(/%/,"",$5); print $5}')
if [ -z "$USED" ]; then
    USED=$(vm_stat | awk '
        /Pages active/ {a=$3}
        /Pages wired/ {w=$4}
        /Pages occupied by compressor/ {c=$5}
        END { printf "%.0f", (a+w+c)*4096/1073741824 }
    ')
    TOTAL=$(sysctl -n hw.memsize | awk '{printf "%.0f", $1/1073741824}')
    USED=$(echo "$USED $TOTAL" | awk '{printf "%.0f", ($1/$2)*100}')
fi

sketchybar --set "$NAME" label="${USED}%"
