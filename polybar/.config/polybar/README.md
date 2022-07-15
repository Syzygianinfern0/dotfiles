## Primary bar
- Network
  - SSID
  - Speed
  - networkmanager_dmenu
- Audio
  - Output (scroll)
  - Input (scroll)
  - Pavucontrol
- Workspaces
- Time
  - India
  - Date/Day
  - Calendar
- Brightness
- Battery

## Secondary bar
- Audio (spotify)
- Updates
- System tray
- Weather

## Kanged From

- Alpha: https://github.com/leetApe/new-bspdots
- Beta: https://github.com/juminai/bspdots
- Gamma: Beta modded to my catppuccin and bars like above
- Delta: https://github.com/mahmoudk1000/dotfiles/tree/master/polybar

## Backlight permissions

```shell
sudo usermod -a -G video catling

sudo tee -a /etc/udev/rules.d/backlight.rules >/dev/null <<EOF
RUN+="/bin/chgrp video /sys/class/backlight/amdgpu_bl0/brightness"
RUN+="/bin/chmod g+w /sys/class/backlight/amdgpu_bl0/brightness"
EOF

# https://wiki.archlinux.org/title/Backlight#ACPI

# ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="amdgpu_bl0", GROUP="video", MODE="0664"

# sudo chgrp video /sys/class/backlight/amdgpu_bl0/brightness
# sudo chmod g+rw /sys/class/backlight/amdgpu_bl0/brightness
```