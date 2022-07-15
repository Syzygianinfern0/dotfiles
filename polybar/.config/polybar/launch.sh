#!/bin/bash

## Files and Directories
DIR="$HOME/.config/polybar"
SFILE="$DIR/system.ini"

## Get system variable values for various modules
get_values() {
    CARD=$(basename "$(find /sys/class/backlight/* | head -n 1)")
    BATTERY=$(basename "$(find /sys/class/power_supply/*BAT* | head -n 1)")
    ADAPTER=$(basename "$(find /sys/class/power_supply/*AC* | head -n 1)")
    INTERFACE=$(ip link | awk '/state UP/ {print $2}' | tr -d :)
}

## Write values to `system` file
set_values() {
    if [[ "$ADAPTER" ]]; then
        sed -i -e "s/adapter = .*/adapter = $ADAPTER/g" "$SFILE"
    fi
    if [[ "$BATTERY" ]]; then
        sed -i -e "s/battery = .*/battery = $BATTERY/g" "$SFILE"
    fi
    if [[ "$CARD" ]]; then
        sed -i -e "s/graphics_card = .*/graphics_card = $CARD/g" "$SFILE"
    fi
    if [[ "$INTERFACE" ]]; then
        sed -i -e "s/network_interface = .*/network_interface = $INTERFACE/g" "$SFILE"
    fi
}

## Launch Polybar with selected style
launch_bar() {
    #    if [[ -z "$CARD" ]]; then
    #        sed -i -e 's/backlight/bna/g' "$DIR"/config.ini
    #    elif [[ "$CARD" != *"intel_"* ]]; then
    #        sed -i -e 's/backlight/brightness/g' "$DIR"/config.ini
    #    fi
    #
    #    if [[ "$INTERFACE" == e* ]]; then
    #        sed -i -e 's/network/ethernet/g' "$DIR"/config.ini
    #    fi

    if [[ ! $(pidof polybar) ]]; then
        # Alpha bar
        # polybar -q bar-left -c "$DIR"/alpha/config.ini &
        # polybar -q bar-center -c "$DIR"/alpha/config.ini &
        # polybar -q bar-right -c "$DIR"/alpha/config.ini &
        # polybar -q bar-power -c "$DIR"/alpha/config.ini &

        # Beta bar (top padding 70)
        # polybar -q spotify -c "$DIR"/beta/config.ini &
        # polybar -q weather -c "$DIR"/beta/config.ini &
        # polybar -q updates -c "$DIR"/beta/config.ini &
        # polybar -q bspwm -c "$DIR"/beta/config.ini &
        # polybar -q memory -c "$DIR"/beta/config.ini &
        # polybar -q cpu -c "$DIR"/beta/config.ini &
        # polybar -q pulseaudio -c "$DIR"/beta/config.ini &
        # polybar -q date -c "$DIR"/beta/config.ini &

        # Gamma bar (top padding 70)
        rm /tmp/first_bar
        rm /tmp/second_bar
        polybar -q bspwm -c "$DIR"/gamma/config.ini & echo $! >> /tmp/first_bar
        polybar -q network -c "$DIR"/gamma/config.ini & echo $! >> /tmp/first_bar
        polybar -q network-speed -c "$DIR"/gamma/config.ini & echo $! >> /tmp/first_bar
        polybar -q pulseaudio -c "$DIR"/gamma/config.ini & echo $! >> /tmp/first_bar
        polybar -q date -c "$DIR"/gamma/config.ini & echo $! >> /tmp/first_bar
        polybar -q updates -c "$DIR"/gamma/config.ini & echo $! >> /tmp/first_bar
        polybar -q spotify -c "$DIR"/gamma/config.ini & echo $! >> /tmp/first_bar
        polybar -q weather -c "$DIR"/gamma/config.ini & echo $! >> /tmp/first_bar
        polybar -q hardware-stats -c "$DIR"/gamma/config.ini & echo $! >> /tmp/first_bar
        polybar -q battery -c "$DIR"/gamma/config.ini & echo $! >> /tmp/second_bar
        sleep 1 # wait for above commands to complete running ig
        "$HOME"/.config/polybar/gamma/cycle_bar.sh -1

        # Delta bar (top padding 45);
        # polybar -q right -c "$DIR"/delta/config.ini &
        # polybar -q center -c "$DIR"/delta/config.ini &
        # polybar -q left -c "$DIR"/delta/config.ini &

    else
        polybar-msg cmd restart
    fi
}

# Execute functions
get_values
set_values

launch_bar
