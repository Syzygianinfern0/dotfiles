#!/bin/bash

while getopts "012" flag; do
    case "$flag" in
    0)
        # hide first par
        while read -r each_bar; do
            polybar-msg -p "$each_bar" cmd hide
        done </tmp/first_bar

        # hide second bar
        while read -r each_bar; do
            polybar-msg -p "$each_bar" cmd hide
        done </tmp/second_bar

        # remove bspwm top padding
        bspc config -m focused top_padding 0
        ;;
    1)
        # show first bar
        while read -r each_bar; do
            polybar-msg -p "$each_bar" cmd show
        done </tmp/first_bar

        # hide second bar
        while read -r each_bar; do
            polybar-msg -p "$each_bar" cmd hide
        done </tmp/second_bar

        # add bspwm top padding
        bspc config -m focused top_padding 60
        ;;
    2)
        # hide first bar
        while read -r each_bar; do
            polybar-msg -p "$each_bar" cmd hide
        done </tmp/first_bar

        # hide second bar
        while read -r each_bar; do
            polybar-msg -p "$each_bar" cmd show
        done </tmp/second_bar

        # add bspwm top padding
        bspc config -m focused top_padding 60
        ;;
    *)
        echo "Wrong!!"
        ;;
    esac
done
