#!/bin/bash
# Its better to run each line in this bash script line by line rather than at a
# stretch cuz its not that good. It also creates ~/.ctan ~/perl5 and a few lines
# in the ~/.(bash/zsh)rc for fixing the perl5 paths. So I dont really like this
# script cuz its too invasive for me. But if there is no other option, I would
# run it. Or just make an alias or a Makefile with a bunch of ln -s commands for
# the project you wanna use stow for.

set -euo pipefail

mkdir -p ~/.local/{bin,src}

# Install the Test::Output Perl package
cd ~/.local/src/
wget https://github.com/briandfoy/test-output/archive/refs/tags/release-1.033.zip
unzip release-1.033.zip
cd test-output-release-1.033
cpan Test::Output

# Install the stow itself
cd ~/.local/src/
wget http://ftp.gnu.org/gnu/stow/stow-latest.tar.gz
tar -xvf stow-latest.tar.gz
cd stow-*
./configure --prefix="$HOME"/.local/bin/stow-bin
make
make install
