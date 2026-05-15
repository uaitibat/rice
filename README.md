# Dotfiles

Configurações pessoais para Arch Linux/Hyprland.

## Conteúdo

- `.config/dunst`
- `.config/hypr`
- `.config/kitty`
- `.config/nvim`
- `.config/obs-cava`
- `.config/rofi`
- `.config/wallust`
- `.config/waybar`
- `.bashrc`
- `wallpapers/`
- `pkglist.txt`: pacotes dos repositórios oficiais
- `aurlist.txt`: pacotes do AUR
- `scripts/install.sh`: instalador

## Instalação

```bash
git clone https://github.com/uaitibat/rice.git
cd rice
chmod +x scripts/install.sh
./scripts/install.sh
```

O script:

1. ativa o repositório `multilib` em `/etc/pacman.conf`;
2. instala `git`, `base-devel` e `yay`, se necessário;
3. instala os pacotes da `pkglist.txt` com `pacman`;
4. instala os pacotes da `aurlist.txt` com `yay`;
5. copia as configs de `.config/` para `~/.config/`.
6. copia `.bashrc` para `~/.bashrc`.
7. copia os wallpapers para `~/Pictures/wallpapers/`.

Antes de rodar em uma instalação existente, revise as listas e faça backup das configs atuais se quiser preservar alterações locais.
