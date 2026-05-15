#!/usr/bin/env bash

set -Eeuo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
PKGLIST="$REPO_DIR/pkglist.txt"
AURLIST="$REPO_DIR/aurlist.txt"
YAY_BUILD_DIR="${YAY_BUILD_DIR:-/tmp/yay-build}"

log() {
    printf '\n==> %s\n' "$*"
}

die() {
    printf 'Erro: %s\n' "$*" >&2
    exit 1
}

require_arch() {
    [[ -f /etc/arch-release ]] || die "este script foi feito para Arch Linux."
    command -v sudo >/dev/null 2>&1 || die "sudo não encontrado."
    command -v pacman >/dev/null 2>&1 || die "pacman não encontrado."
}

read_packages() {
    local file="$1"

    [[ -f "$file" ]] || return 0

    sed 's/#.*$//' "$file" \
        | awk 'NF { print $1 }' \
        | sort -u
}

enable_multilib() {
    if grep -Eq '^\s*\[multilib\]' /etc/pacman.conf; then
        log "Multilib já está ativo."
        return
    fi

    log "Ativando repositório multilib em /etc/pacman.conf..."
    sudo cp /etc/pacman.conf /etc/pacman.conf.bak
    sudo sed -i '/^#\[multilib\]/{s/^#//;n;s/^#//;}' /etc/pacman.conf

    if ! grep -Eq '^\s*\[multilib\]' /etc/pacman.conf; then
        die "não consegui ativar o multilib automaticamente. Veja /etc/pacman.conf."
    fi
}

install_yay() {
    if command -v yay >/dev/null 2>&1; then
        log "yay já está instalado."
        return
    fi

    log "Instalando dependências base e yay..."
    sudo pacman -S --needed --noconfirm git base-devel
    rm -rf "$YAY_BUILD_DIR"
    git clone https://aur.archlinux.org/yay.git "$YAY_BUILD_DIR"
    (cd "$YAY_BUILD_DIR" && makepkg -si --noconfirm)
}

install_official_packages() {
    mapfile -t aur_packages < <(read_packages "$AURLIST")
    mapfile -t packages < <(comm -23 <(read_packages "$PKGLIST") <(printf '%s\n' "${aur_packages[@]}" | sort -u))

    if ((${#packages[@]} == 0)); then
        log "Nenhum pacote oficial para instalar."
        return
    fi

    log "Instalando pacotes oficiais..."
    sudo pacman -S --needed --noconfirm "${packages[@]}"
}

install_aur_packages() {
    mapfile -t packages < <(read_packages "$AURLIST")

    if ((${#packages[@]} == 0)); then
        log "Nenhum pacote AUR para instalar."
        return
    fi

    log "Instalando pacotes AUR..."
    yay -S --needed --noconfirm "${packages[@]}"
}

copy_configs() {
    local config_src="$REPO_DIR/.config"
    local config_dest="$HOME/.config"

    [[ -d "$config_src" ]] || die "pasta .config não encontrada no repositório."

    log "Copiando configs para $config_dest..."
    mkdir -p "$config_dest"
    cp -a "$config_src"/. "$config_dest"/
}

copy_bashrc() {
    local bashrc_src="$REPO_DIR/.bashrc"
    local bashrc_dest="$HOME/.bashrc"

    [[ -f "$bashrc_src" ]] || return

    log "Copiando .bashrc para $bashrc_dest..."
    cp -a "$bashrc_src" "$bashrc_dest"
}

copy_wallpapers() {
    local wallpapers_src="$REPO_DIR/wallpapers"
    local wallpapers_dest="$HOME/Pictures/wallpapers"

    [[ -d "$wallpapers_src" ]] || return

    log "Copiando wallpapers para $wallpapers_dest..."
    mkdir -p "$wallpapers_dest"
    cp -a "$wallpapers_src"/. "$wallpapers_dest"/
}

main() {
    require_arch
    enable_multilib

    log "Atualizando pacman..."
    sudo pacman -Syu --noconfirm

    install_yay
    install_official_packages
    install_aur_packages
    copy_configs
    copy_bashrc
    copy_wallpapers

    log "Finalizado."
}

main "$@"
