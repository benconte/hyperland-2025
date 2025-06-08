#!/bin/bash
# Handle media control with notifications
# $1 = command (next, previous, play-pause)

# Check if we have a selected player
SELECTED_FILE="$HOME/dotfiles/.config/hypr/scripts/selected_player"
if [ -f "$SELECTED_FILE" ]; then
    PLAYER=$(cat "$SELECTED_FILE")
    playerctl --player="$PLAYER" "$1"
else
    # Otherwise control the active player
    playerctl "$1"
    PLAYER=$(playerctl -l | head -n 1)
fi

# Get current player status
STATUS=$(playerctl --player="$PLAYER" status 2>/dev/null)
ARTIST=$(playerctl --player="$PLAYER" metadata artist 2>/dev/null)
TITLE=$(playerctl --player="$PLAYER" metadata title 2>/dev/null)

# Prepare notification
if [ "$STATUS" = "Playing" ]; then
    ICON="media-playback-start"
    if [ -n "$ARTIST" ] && [ -n "$TITLE" ]; then
        MESSAGE="$ARTIST - $TITLE"
    else
        MESSAGE="Now playing on $PLAYER"
    fi
elif [ "$STATUS" = "Paused" ]; then
    ICON="media-playback-pause"
    MESSAGE="Paused on $PLAYER"
else
    ICON="media-playback-stop"
    MESSAGE="Stopped on $PLAYER"
fi

# Show notification
notify-send -h string:x-dunst-stack-tag:media "Media ($1)" "$MESSAGE" --icon=$ICON
