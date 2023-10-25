#!/bin/bash

set -ex

log() { echo "$1" >&2; }
fail() { log "$1"; exit 1; }

release=${1:-v1.1.3}

log "Installing FSM version $release"

./install_fsm.sh $release
# Add FSM to your path
export PATH=$PATH:$HOME/.fsm/bin
# Verify the CLI is installed and running correctly
fsm version

# Install FSM
fsm install

# Check installation
fsm version