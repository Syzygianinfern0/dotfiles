#!/bin/bash
cd /tmp
curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-$(uname)-$(uname -m).sh"
bash Mambaforge-$(uname)-$(uname -m).sh

mamba activate base
pip install pipx
pipx install pre-commit
pipx install black
pipx install nvitop
