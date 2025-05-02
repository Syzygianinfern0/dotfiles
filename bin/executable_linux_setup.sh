#!/bin/bash
wget https://downloads.rclone.org/rclone-current-linux-amd64.zip
unzip rclone-current-linux-amd64.zip
./rclone*/rclone copy -P personal:linux_bin_x bin/linux_bin/ --drive-acknowledge-abuse
chmod +x bin/linux_bin/*
rm -rf age* rclone*
