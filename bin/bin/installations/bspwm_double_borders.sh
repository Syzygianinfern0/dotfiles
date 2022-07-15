#!/bin/bash

mkdir -p "$HOME"/.local/src/
cd "$HOME"/.local/src/
git clone https://github.com/wmutils/opt.git
cd opt
make
sudo make install
