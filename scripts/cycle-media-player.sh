#!/bin/bash
# Cycle between available media players and set as active for playerctl

# Get list of active players
PLAYERS=$(playerctl -l 2>/dev/null)

if [ -z "$PLAYERS" ]; then
    notify-send "Media Control" "No active media players found" --icon=dialog-information
    exit 0
fi

# Create an array of players
IFS=$'\n' read -rd '' -a PLAYER_ARRAY <<< "$PLAYERS"

# Check if there's a currently selected player stored
SELECTED_FILE="$HOME/dotfiles/.config/hypr/scripts/selected_player"
if [ -f "$SELECTED_FILE" ]; then
    CURRENT=$(cat "$SELECTED_FILE")
else
    CURRENT=""
fi

# Find the index of the current player
CURRENT_IDX=-1
for i in "${!PLAYER_ARRAY[@]}"; do
    if [ "${PLAYER_ARRAY[$i]}" = "$CURRENT" ]; then
        CURRENT_IDX=$i
        break
    fi
done

# Get the next player index
NEXT_IDX=$(( (CURRENT_IDX + 1) % ${#PLAYER_ARRAY[@]} ))
NEXT_PLAYER="${PLAYER_ARRAY[$NEXT_IDX]}"

# Save the selection
echo "$NEXT_PLAYER" > "$SELECTED_FILE"

# Set PlayerCTL_PLAYER environment variable
export PLAYERCTL_PLAYER="$NEXT_PLAYER"

# Get player status
STATUS=$(playerctl --player="$NEXT_PLAYER" status 2>/dev/null || echo "Unknown")
ARTIST=$(playerctl --player="$NEXT_PLAYER" metadata artist 2>/dev/null)
TITLE=$(playerctl --player="$NEXT_PLAYER" metadata title 2>/dev/null)

# Prepare notification message
if [ -n "$ARTIST" ] && [ -n "$TITLE" ]; then
    MESSAGE="$ARTIST - $TITLE"
else
    MESSAGE="Status: $STATUS"
fi

# Notify user
notify-send -h string:x-dunst-stack-tag:media "Controlling: $NEXT_PLAYER" "$MESSAGE" --icon=audio-headphones
