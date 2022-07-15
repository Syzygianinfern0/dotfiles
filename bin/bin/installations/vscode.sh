#!/bin/bash

cd "$HOME"/Downloads/
wget "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" -O vscode.deb
sudo apt install -y ./vscode.deb
