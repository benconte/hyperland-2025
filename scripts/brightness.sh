#!/bin/bash

case "$1" in
    up)
        brightnessctl -q s +10%
        ;;
    down)
        brightnessctl -q s 5%-
        ;;
    *)
        echo "Usage: $0 {up|down}"
        exit 1
        ;;
esac

# Get current brightness percentage
current=$(brightnessctl g)
max=$(brightnessctl m)
percentage=$((current * 100 / max))

# Send notification with progress bar
notify-send "Brightness" "${percentage}%" \
    -h int:value:${percentage} \
    -h string:synchronous:brightness \
    -t 1500 \
    -i display-brightness-symbolic
