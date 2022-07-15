#!/bin/sh

killall -9 sxhkd dunst flameshot polybar picom greenclip autotiling nm-applet
sxhkd -c "$HOME"/.config/sxhkd/common "$HOME"/.config/sxhkd/i3 &
dunst &
flameshot &
# "$HOME"/.config/polybar/launch.sh
picom &
greenclip daemon &
autotiling &
nm-applet &

nitrogen --restore &
/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1 &
