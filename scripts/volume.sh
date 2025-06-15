#!/bin/bash

get_volume() {
    pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '\d+(?=%)' | head -1
}

is_muted() {
    pactl get-sink-mute @DEFAULT_SINK@ | grep -q "yes"
}

send_notification() {
    local volume=$(get_volume)
    local icon=""
    local text=""
    
    if is_muted; then
        icon="audio-volume-muted-symbolic"
        text="Muted"
        notify-send "Volume" "$text" \
            -h int:value:0 \
            -h string:synchronous:volume \
            -t 1500 \
            -i "$icon"
    else
        if [ "$volume" -eq 0 ]; then
            icon="audio-volume-muted-symbolic"
        elif [ "$volume" -lt 33 ]; then
            icon="audio-volume-low-symbolic"
        elif [ "$volume" -lt 66 ]; then
            icon="audio-volume-medium-symbolic"
        else
            icon="audio-volume-high-symbolic"
        fi
        
        notify-send "Volume" "${volume}%" \
            -h int:value:"$volume" \
            -h string:synchronous:volume \
            -t 1500 \
            -i "$icon"
    fi
}

case "$1" in
    up)
        pactl set-sink-mute @DEFAULT_SINK@ 0
        pactl set-sink-volume @DEFAULT_SINK@ +5%
        send_notification
        ;;
    down)
        pactl set-sink-mute @DEFAULT_SINK@ 0
        pactl set-sink-volume @DEFAULT_SINK@ -5%
        send_notification
        ;;
    mute)
        pactl set-sink-mute @DEFAULT_SINK@ toggle
        send_notification
        ;;
    *)
        echo "Usage: $0 {up|down|mute}"
        exit 1
        ;;
esac
