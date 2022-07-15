#!/bin/bash

mode=$(cat /sys/devices/platform/asus-nb-wmi/throttle_thermal_policy)
speed=$(sensors | grep -Po "[0-9]+ RPM")
case $mode in
0)
  echo " Normal"
  ;;
1)
    echo " Turbo"
    ;;
2)
    echo " Silent"
    ;;
esac
