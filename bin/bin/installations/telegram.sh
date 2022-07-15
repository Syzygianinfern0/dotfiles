#!/bin/bash

cd "$HOME"/Downloads/
wget https://telegram.org/dl/desktop/linux -O telegram.tar.xz
tar xvf telegram.tar.xz
mkdir -p "$HOME"/Applications
mv Telegram/ "$HOME"/Applications
