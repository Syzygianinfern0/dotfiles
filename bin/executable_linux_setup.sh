#!/bin/bash
wget https://downloads.rclone.org/rclone-current-linux-amd64.zip
unzip rclone-current-linux-amd64.zip
./rclone*/rclone copy -P personal:linux_bin_x bin/linux_bin/ --drive-acknowledge-abuse
rm -rf age* rclone*
