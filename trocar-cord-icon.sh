#!/usr/bin/env bash
set -euo pipefail

config_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
init_lua="$config_dir/init.lua"

printf "Link da foto/GIF para o Discord Rich Presence: "
IFS= read -r icon_url

if [[ -z "${icon_url// }" ]]; then
  printf "Nenhum link informado. Nada foi alterado.\n" >&2
  exit 1
fi

tmp_file="$(mktemp)"
trap 'rm -f "$tmp_file"' EXIT

awk -v icon_url="$icon_url" '
  function lua_quote(value) {
    gsub(/\\/, "\\\\", value)
    gsub(/"/, "\\\"", value)
    return value
  }

  /\["Cord\.override"\][[:space:]]*=/ {
    in_override = 1
  }

  in_override && /^[[:space:]]*icon[[:space:]]*=/ && !updated {
    match($0, /^[[:space:]]*/)
    indent = substr($0, RSTART, RLENGTH)
    $0 = indent "icon = \"" lua_quote(icon_url) "\","
    updated = 1
    in_override = 0
  }

  { print }

  END {
    if (!updated) {
      exit 2
    }
  }
' "$init_lua" > "$tmp_file" || {
  status=$?
  if [[ "$status" -eq 2 ]]; then
    printf "Nao encontrei o bloco Cord.override em %s.\n" "$init_lua" >&2
  fi
  exit "$status"
}

mv "$tmp_file" "$init_lua"
trap - EXIT

printf "Icone atualizado em %s.\n" "$init_lua"
printf "Reabra o Neovim ou rode :Cord restart.\n"
