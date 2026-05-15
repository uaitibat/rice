#!/usr/bin/env bash

set -eu

APP="/mnt/coisas2/Backup_do_arch_btw/scripts/anime-tracker/animedash/target/debug/animedash"

if pgrep -f "^${APP}$" >/dev/null 2>&1; then
    pkill -f "^${APP}$"
else
    "$APP" >/dev/null 2>&1 &
fi
