#!/usr/bin/env bash

set -eu

wallpaper="${1:-}"
if [ -z "$wallpaper" ] || [ ! -f "$wallpaper" ]; then
  exit 0
fi

if ! command -v wallust >/dev/null 2>&1; then
  exit 0
fi

# Generate/update palette cache for current wallpaper.
wallust run -q -s -T -w "$wallpaper" >/dev/null 2>&1 || exit 0

latest_dark_file="$({ find "${XDG_CACHE_HOME:-$HOME/.cache}/wallust" -type f -name '*Dark' -printf '%T@ %p\n' 2>/dev/null || true; } | sort -nr | head -n1 | cut -d' ' -f2-)"
if [ -z "$latest_dark_file" ] || [ ! -f "$latest_dark_file" ]; then
  exit 0
fi

extract_color() {
  local key="$1"
  sed -n "s/.*\"${key}\": \"\(#[0-9A-Fa-f]\{6\}\)\".*/\1/p" "$latest_dark_file" | head -n1
}

active_hex="$(extract_color color4)"
inactive_hex="$(extract_color color8)"

[ -z "$active_hex" ] && active_hex="#ffffff"
[ -z "$inactive_hex" ] && inactive_hex="#808080"

active_rgba="rgba(${active_hex#\#}ff)"
inactive_rgba="rgba(${inactive_hex#\#}ff)"

hypr_conf="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/hyprland.conf"
if [ -f "$hypr_conf" ]; then
  sed -i -E \
    -e "s|^([[:space:]]*col\.active_border[[:space:]]*=[[:space:]]*).*$|\1${active_rgba}|" \
    -e "s|^([[:space:]]*col\.inactive_border[[:space:]]*=[[:space:]]*).*$|\1${inactive_rgba}|" \
    "$hypr_conf"
fi

waybar_css="${XDG_CONFIG_HOME:-$HOME/.config}/waybar/style.css"
if [ -f "$waybar_css" ]; then
  if grep -q '^@define-color[[:space:]]\+widget_border' "$waybar_css"; then
    sed -i -E "s|^@define-color[[:space:]]+widget_border[[:space:]]+#[0-9A-Fa-f]{6};$|@define-color widget_border ${active_hex};|" "$waybar_css"
  fi
fi

rofi_colors="${XDG_CONFIG_HOME:-$HOME/.config}/rofi/wallust-colors.rasi"
if [ -d "$(dirname "$rofi_colors")" ]; then
  cat > "$rofi_colors" <<EOF
* {
    wallust-accent: ${active_hex};
    border-color:   ${active_hex};
}
EOF
fi

dunst_conf="${XDG_CONFIG_HOME:-$HOME/.config}/dunst/dunstrc"
if [ -f "$dunst_conf" ]; then
  perl -0pi -e "s/(\\[global\\].*?frame_color\\s*=\\s*\")[^\"]*(\")/\${1}${active_hex}\${2}/s" "$dunst_conf"
  perl -0pi -e "s/(\\[global\\].*?highlight\\s*=\\s*\")[^\"]*(\")/\${1}${active_hex}\${2}/s" "$dunst_conf"
  perl -0pi -e "s/(\\[urgency_low\\].*?frame_color\\s*=\\s*\")[^\"]*(\")/\${1}${inactive_hex}\${2}/s" "$dunst_conf"
  perl -0pi -e "s/(\\[urgency_low\\].*?highlight\\s*=\\s*\")[^\"]*(\")/\${1}${inactive_hex}\${2}/s" "$dunst_conf"
  perl -0pi -e "s/(\\[urgency_normal\\].*?frame_color\\s*=\\s*\")[^\"]*(\")/\${1}${active_hex}\${2}/s" "$dunst_conf"
  perl -0pi -e "s/(\\[urgency_normal\\].*?highlight\\s*=\\s*\")[^\"]*(\")/\${1}${active_hex}\${2}/s" "$dunst_conf"
fi

cava_conf="${XDG_CONFIG_HOME:-$HOME/.config}/cava/config"
if [ -f "$cava_conf" ]; then
  perl -0pi -e "s/^[;#\\s]*gradient\\s*=.*$/gradient = 1/m" "$cava_conf"
  perl -0pi -e "s/^[;#\\s]*gradient_color_1\\s*=.*$/gradient_color_1 = '${active_hex}'/m" "$cava_conf"
  perl -0pi -e "s/^[;#\\s]*gradient_color_2\\s*=.*$/gradient_color_2 = '${inactive_hex}'/m" "$cava_conf"
  perl -0pi -e "s/^[;#\\s]*background\\s*=.*$/background = default/m" "$cava_conf"
  perl -0pi -e "s/^[;#\\s]*foreground\\s*=.*$/foreground = default/m" "$cava_conf"
  pkill -USR2 cava >/dev/null 2>&1 || true
fi

if command -v hyprctl >/dev/null 2>&1; then
  hyprctl reload >/dev/null 2>&1 || true
fi

if pgrep -x waybar >/dev/null 2>&1; then
  pkill -x waybar || true
  nohup waybar >/dev/null 2>&1 &
fi

if systemctl --user --quiet is-active dunst.service 2>/dev/null; then
  systemctl --user restart dunst.service >/dev/null 2>&1 || true
elif pgrep -x dunst >/dev/null 2>&1; then
  pkill -x dunst || true
  nohup dunst >/dev/null 2>&1 &
fi
