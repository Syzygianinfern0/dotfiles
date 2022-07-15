#!/bin/bash

# https://www.jetbrains.com/pycharm/download/download-thanks.html?platform=linux
cd "$HOME"/Downloads/
sudo tar xzf pycharm-*.tar.gz -C /opt/
cd /opt/pycharm-*/bin
sh pycharm.sh
