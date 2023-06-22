#!/bin/bash
cd /tmp
curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-$(uname)-$(uname -m).sh"
bash Mambaforge-$(uname)-$(uname -m).sh -b -p ~/mambaforge

source ~/mambaforge/etc/profile.d/conda.sh
mamba activate base
mamba update --all -y
pip install pipx
pipx install pre-commit --force
pipx install black --force
pipx install nvitop --force
