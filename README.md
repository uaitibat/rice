<div align="center">

# uaitiDots

Minhas configs básicas para Arch Linux + Hyprland.

<img src="assets/preview.gif" width="760" alt="Preview do rice">

<br>

<table>
  <tr>
    <td align="center" width="50%">
      <img src="assets/desktop.png" alt="Desktop Hyprland" width="100%">
      <br>
      <sub>Hyprland + Waybar</sub>
    </td>
    <td align="center" width="50%">
      <img src="assets/wallpaper.png" alt="Wallpaper e Wallust" width="100%">
      <br>
      <sub>Wallpapers + Wallust</sub>
    </td>
  </tr>
</table>

</div>

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
5. copia as configs de `.config/` para `~/.config/`;
6. copia `.bashrc` para `~/.bashrc`;
7. copia os wallpapers para `~/Pictures/wallpapers/`.

<div align="center">

<img src="https://i.pinimg.com/originals/f8/43/51/f84351996a1ed0c79bcc35b40093ab19.gif" width="760" alt="Sakura gif">

</div>

## Observação

Revise as listas e faça backup das configs atuais antes de rodar em uma instalação existente.
