#!/usr/bin/env bash

# regenerate HW config and template config
sudo nixos-generate-config --dir ~/.dotfiles/nixos/hosts/$HOSTNAME

# rm generated template config file
rm ~/.dotfiles/nixos/hosts/$HOSTNAME/configuration.nix
