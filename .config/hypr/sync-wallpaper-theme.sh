#!/usr/bin/env bash

set -eu

config_file="${XDG_CONFIG_HOME:-$HOME/.config}/waypaper/config.ini"
[ -f "$config_file" ] || exit 0

wallpaper="$(sed -n 's/^wallpaper = //p' "$config_file" | head -n1)"
[ -n "$wallpaper" ] || exit 0

"${XDG_CONFIG_HOME:-$HOME/.config}/hypr/update-theme-from-wallust.sh" "$wallpaper"
