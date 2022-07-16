#!/bin/bash

dir=$(dirname "$0")
theme="minimal_center"
#theme="minimal_fullscreen"
#theme="icons_center"

rofi \
  -show drun \
  -modi run,drun,window \
  -no-lazy-grab \
  -drun-match-fields all \
  -drun-show-actions \
  -theme "$dir"/"$theme"
