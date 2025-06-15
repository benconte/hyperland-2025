#!/bin/bash

get_mic_volume() {
    pactl get-source-volume @DEFAULT_SOURCE@ | grep -Po '\d+(?=%)' | head -1
}

is_mic_muted() {
    pactl get-source-mute @DEFAULT_SOURCE@ | grep -q "yes"
}

send_notification() {
    local volume=$(get_mic_volume)
    local icon=""
    local text=""
    
    if is_mic_muted; then
        icon="microphone-sensitivity-muted-symbolic"
        text="Microphone Muted"
        notify-send "Microphone" "$text" \
            -h int:value:0 \
            -h string:synchronous:microphone \
            -t 1500 \
            -i "$icon"
    else
        if [ "$volume" -eq 0 ]; then
            icon="microphone-sensitivity-muted-symbolic"
        elif [ "$volume" -lt 33 ]; then
            icon="microphone-sensitivity-low-symbolic"
        elif [ "$volume" -lt 66 ]; then
            icon="microphone-sensitivity-medium-symbolic"
        else
            icon="microphone-sensitivity-high-symbolic"
        fi
        
        text="Microphone ${volume}%"
        notify-send "Microphone" "$text" \
            -h int:value:"$volume" \
            -h string:synchronous:microphone \
            -t 1500 \
            -i "$icon"
    fi
}

case "$1" in
    toggle)
        pactl set-source-mute @DEFAULT_SOURCE@ toggle
        send_notification
        ;;
    up)
        pactl set-source-mute @DEFAULT_SOURCE@ 0
        pactl set-source-volume @DEFAULT_SOURCE@ +5%
        send_notification
        ;;
    down)
        pactl set-source-mute @DEFAULT_SOURCE@ 0
        pactl set-source-volume @DEFAULT_SOURCE@ -5%
        send_notification
        ;;
    *)
        echo "Usage: $0 {toggle|up|down}"
        exit 1
        ;;
esac
