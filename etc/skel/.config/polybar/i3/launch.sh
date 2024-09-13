#!/usr/bin/env bash

# Add this script to your wm startup file.

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch the bar
polybar -q main -c ~/.config/polybar/i3/panel/bottom.ini &
polybar -q mac -c ~/.config/polybar/i3/panel/top.ini &