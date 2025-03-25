#!/usr/bin/env bash

POSITIONAL_ARGS=()
UPDATE=false
UPDATE_HW=false
REBUILD=true

while [[ $# -gt 0 ]]; do
  case $1 in
    --help | -h)
      echo -e "Script to auto rebuild NixOS system\n"
      echo -e "-n, --no-rebuild\n\tDon't rebuild system"
      echo -e "-u, --update\n\tUpdate flake.lock"
      echo -e "-e, --update-hw\n\tUpdate hardware-configuration.nix"
      echo -e "    --hostname\n\tHostname to use for rebuild"
      exit 0
      ;;
    --update | -u)
      UPDATE=true
      shift # past argument
      ;;
    --update-hw | -e)
      UPDATE_HW=true
      shift # past argument
      ;;
    --no-rebuild | -n)
      REBUILD=false
      shift # past argument
      ;;
    --hostname)
      shift # past argument
      HOSTNAME="$1"
      shift
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      echo "erm what the sigma is $1, exiting"
      exit 1
      ;;
  esac
done

if [[ "$UPDATE" == "true" ]]; then
  echo "UPDATING FLAKE..."
  # update flake.lock
  sudo nix flake update
fi

if [[ "$UPDATE_HW" == "true" ]]; then
  echo "UPDATING HARDWARE CONFIG..."
  # regenerate HW config and template config, rm template config
  sudo nixos-generate-config --dir "$HOME/.dotfiles/nixos/hosts/$HOSTNAME"
  rm "$HOME/.dotfiles/nixos/hosts/$HOSTNAME/configuration.nix"
fi

if [[ "$REBUILD" == "true" ]]; then
  echo "REBUILDING..."
  # basic rebuild
  # `#$HOSTNAME` will return "#orion" which is intended
  sudo nixos-rebuild switch --flake "$HOME/.dotfiles/nixos/#$HOSTNAME"
fi

