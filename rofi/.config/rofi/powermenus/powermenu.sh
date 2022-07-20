#!/bin/bash

dir=$(dirname "$0")
theme="minimal_center"

rofi_command="rofi -theme $dir/$theme"

# Options
#shutdown=""
#reboot=""
#lock=""
#suspend=""
#logout=""
shutdown="shutdown"
reboot="reboot"
lock="lock"
suspend="suspend"
logout="logout"

# Variable passed to rofi
options="$shutdown\n$reboot\n$lock\n$suspend\n$logout"

chosen="$(echo -e "$options" | $rofi_command -p "" -dmenu)"
echo "$chosen"

case $chosen in
shutdown) systemctl shutdown ;;
reboot) systemctl reboot ;;
lock) i3lock ;;
suspend) systemctl suspend ;;
logout) i3-msg exit ;;
esac
