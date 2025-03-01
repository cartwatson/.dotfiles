#!/usr/bin/env bash

sudo nixos-generate-config --dir ~/.dotfiles/nixos/hosts/$HOSTNAME

# only a template file
rm ~/.dotfiles/nixos/hosts/$HOSTNAME/configuration.nix
