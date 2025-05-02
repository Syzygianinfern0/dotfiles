#!/bin/bash

BASH_PROFILE="$HOME/.bash_profile"
BLOCK_START="# Start Zsh only if it's not already running"
BLOCK_CONTENT="${BLOCK_START}
if [ -z \"\$ZSH_VERSION\" ]; then
    exec zsh
fi"

# Check if the block is already present
if ! grep -Fxq "$BLOCK_START" "$BASH_PROFILE"; then
    echo -e "\n$BLOCK_CONTENT" >>"$BASH_PROFILE"
    echo "Block added to $BASH_PROFILE."
else
    echo "Block already present in $BASH_PROFILE."
fi
