#!/usr/bin/env bash

# `#$HOSTNAME` will return "#orion" which is intended
sudo nixos-rebuild switch --flake ~/.dotfiles/nixos/#$HOSTNAME
