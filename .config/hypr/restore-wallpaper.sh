#!/usr/bin/env bash

set -eu

config_file="${XDG_CONFIG_HOME:-$HOME/.config}/waypaper/config.ini"

if [ ! -f "$config_file" ]; then
    exit 0
fi

read_setting() {
    sed -n "s/^$1 = //p" "$config_file" | head -n 1
}

wallpaper="$(read_setting wallpaper)"
fill="$(read_setting fill)"
transition_type="$(read_setting swww_transition_type)"
transition_step="$(read_setting swww_transition_step)"
transition_angle="$(read_setting swww_transition_angle)"
transition_duration="$(read_setting swww_transition_duration)"
transition_fps="$(read_setting swww_transition_fps)"

if [ -z "$wallpaper" ] || [ ! -f "$wallpaper" ]; then
    exit 0
fi

if ! pgrep -x swww-daemon >/dev/null 2>&1; then
    awww-daemon >/dev/null 2>&1 &
    sleep 1
fi

awww img "$wallpaper" \
    --resize "${fill:-fill}" \
    --transition-type "${transition_type:-any}" \
    --transition-step "${transition_step:-63}" \
    --transition-angle "${transition_angle:-0}" \
    --transition-duration "${transition_duration:-2}" \
    --transition-fps "${transition_fps:-60}"

"${XDG_CONFIG_HOME:-$HOME/.config}/hypr/update-theme-from-wallust.sh" "$wallpaper"
