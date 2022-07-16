## Install

### Headless

`make headless`

is gonna stow all the configs I need for a server/tty which basically include

- bash
- zsh
- ~/.local/bin scripts

### Everything else

Its not headless ig. Most things are super rough rn and not to be used just like that.

## Todo

- [ ] Core
    - [x] i3
    - [x] sxhkd
    - [x] bar
    - [x] picom
    - [ ] rofi
        - [ ] launcher
        - [ ] clipboard
        - [ ] powermenu
        - [ ] emoji
        - [ ] screenshot
        - [ ] color picker
    - [ ] dunst
    - [ ] pywal
    - [ ] zsh
- [ ] display manager
- [ ] tlp Laptop
- [ ] gestures

## Packages to install

```shell
sudo apt install stow bspwm sxhkd dunst polybar rofi nitrogen libnotify-bin \
    qbittorrent vlc mpv lxappearance jq playerctl picom neofetch pavucontrol \
    pulsemixer brightnessctl htop iw thunar
```

```shell
sudo apt install python3-pip
pip install i3ipc netifaces psutil
```
