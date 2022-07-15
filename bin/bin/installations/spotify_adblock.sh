#!/bin/bash

mkdir -p "$HOME"/.local/src
cd "$HOME"/.local/src
git clone https://github.com/abba23/spotify-adblock.git
cd spotify-adblock
curl https://sh.rustup.rs -sSf | sh
source "$HOME"/.cargo/env
make
sudo make install
sudo sed -i 's@^Exec=spotify@Exec=env LD_PRELOAD=/usr/local/lib/spotify-adblock.so spotify@g' /usr/share/applications/spotify.desktop
