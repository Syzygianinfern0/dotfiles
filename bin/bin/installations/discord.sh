#!/bin/bash

cd "$HOME"/Downloads/
wget "https://discord.com/api/download?platform=linux&format=deb" -O discord.deb
sudo apt install ./discord.deb
