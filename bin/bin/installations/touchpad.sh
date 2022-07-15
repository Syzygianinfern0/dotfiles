#!/bin/bash

sudo tee -a /etc/X11/xorg.conf.d/90-touchpad.conf >/dev/null <<EOF
Section "InputClass"
        Identifier "touchpad"
        MatchIsTouchpad "on"
        Driver "libinput"
        Option "Tapping" "on"
        Option "TappingButtonMap" "lrm"
        Option "NaturalScrolling" "on"
        Option "ScrollMethod" "twofinger"
EndSection
EOF
