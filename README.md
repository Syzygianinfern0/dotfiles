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

- [ ] Basics
    - [x] BSPWM
    - [x] SXHKD
    - [x] Polybar
    - [ ] Rofi
    - [ ] Dunst
    - [ ] Terminal
    - [ ] Pywal
    - [ ] compositor
    - [ ] Zsh theme
- [ ] Clipboard manager
- [ ] tlp for laptop
- [ ] screensaver
- [ ] touchpad gestures: touchegg
- [ ] ksuperkey
- [ ] Double borders
- [ ] Lockscreen
- [ ] Screenshot
- [ ] Emoji
- [ ] Color picker
- [ ] Check out bin folders of reference dotfiles

## Packages to install

- policykit-1-gnome
- bspwm
- polybar
- dmenu
- feh
- bspwm
- dunst
-
flameshot: https://github.com/flameshot-org/flameshot/releases/download/v11.0.0/flameshot-11.0.0-1.ubuntu-20.04.amd64.deb
- code: https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64
- jgmenu
- libnotify-bin
- xfce4-power-manager
- https://github.com/hanschen/ksuperkey
- jq
- playerctl

```shell
sudo apt install stow bspwm sxhkd dunst polybar rofi nitrogen libnotify-bin \
    qbittorrent vlc mpv lxappearance jq playerctl picom neofetch pavucontrol \
    pulsemixer brightnessctl htop iw thunar maim viewnior
```
