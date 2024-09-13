#!/bin/bash

# Define i3 layouts with FontAwesome icons
LAYOUT=$(echo -e " Tabbed\n Stacked\n Split Horizontal\n Split Vertical" | rofi -dmenu -theme ~/.config/polybar/i3/menu/layout.rasi -p "Select Layout")

# Apply selected layout if a valid option is chosen
case "$LAYOUT" in
    " Tabbed")
        i3-msg layout tabbed
        ;;
    " Stacked")
        i3-msg layout stacking
        ;;
    " Split Horizontal")
        i3-msg layout splith
        ;;
    " Split Vertical")
        i3-msg layout splitv
        ;;
esac
