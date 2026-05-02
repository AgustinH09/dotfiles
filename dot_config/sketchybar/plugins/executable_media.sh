#!/bin/bash

STATE=$(osascript -e '
tell application "System Events"
    set musicPlayers to {"Music", "Spotify"}
    repeat with p in musicPlayers
        if (name of processes) contains (p as string) then
            try
                tell application (p as string) to return (get name of current track) & " – " & (get artist of current track)
            end try
        end if
    end repeat
end tell
return ""
' 2>/dev/null)

if [ -n "$STATE" ] && [ "$STATE" != "" ]; then
    sketchybar --set "$NAME" label="$STATE" icon=󰎆
else
    sketchybar --set "$NAME" label="—" icon=󰎇
fi
