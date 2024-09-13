#!/bin/bash

# Get volume level
VOLUME=$(amixer get Master | grep -oP '\d+%' | head -1 | tr -d '%')

# Get mute status
MUTE=$(amixer get Master | grep '\[off\]')

# Determine icon based on volume level
if [[ ! -z "$MUTE" ]]; then
    ICON=""  # Muted
elif [[ "$VOLUME" -le 30 ]]; then
    ICON=""  # Low volume
else
    ICON=""  # High volume
fi

# Output icon and volume
echo "$ICON"
