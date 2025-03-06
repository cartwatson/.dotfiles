#!/usr/bin/env bash

POSITIONAL_ARGS=()
UPDATE=false
UPDATE_HW=false
REBUILD=true

while [[ $# -gt 0 ]]; do
  case $1 in
    --update | -u)
      UPDATE=true
      shift # past argument
      ;;
    --update-hw | -e)
      UPDATE_HW=false
      shift # past argument
      ;;
    --help | -h)
      echo -e "Script to auto rebuild NixOS system\n"
      echo -e "-n, --no-rebuild\n\tDon't rebuild system"
      echo -e "-u, --update\n\tUpdate flake.lock"
      echo -e "-e, --update-hw\n\tUpdate hardware-configuration.nix"
      exit 0
      ;;
    --no-rebuild | -n)
      REBUILD=false
      shift # past argument
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      echo "erm what the sigma is $1, exiting"
      exit 1
      shift # past argument
      ;;
  esac
done

if [[ UPDATE ]]; then
  # update flake.lock
  sudo nix flake update
fi

if [[ UDPATE_HW ]]; then
  # regenerate HW config and template config, rm template config
  sudo nixos-generate-config --dir ~/.dotfiles/nixos/hosts/$HOSTNAME
  rm ~/.dotfiles/nixos/hosts/$HOSTNAME/configuration.nix
fi

if [[ REBUILD ]]; then
  # basic rebuild
  # `#$HOSTNAME` will return "#orion" which is intended
  sudo nixos-rebuild switch --flake ~/.dotfiles/nixos/#$HOSTNAME
fi

