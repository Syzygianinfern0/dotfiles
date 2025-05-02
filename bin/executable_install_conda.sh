#!/bin/bash
cd /tmp
curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
bash Miniforge3-$(uname)-$(uname -m).sh -b

eval "$("$HOME/miniforge3/bin/mamba" shell hook --shell zsh)"
mamba activate base
mamba update --all -y
pip install pipx
pipx install pre-commit --force
pipx install black --force
pipx install nvitop --force
