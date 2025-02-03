#!/usr/bin/env bash

sudo nixos-rebuild switch --flake ~/.dotfiles/nixos/hosts/$HOSTNAME
