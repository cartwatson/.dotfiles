#!/usr/bin/env bash

# exit if any command fails
set -eo pipefail

ISO="false"
UPDATE="false"
UPDATE_HW="false"
REBUILD="true"
CLEANUP="false"

while [[ $# -gt 0 ]]; do
  case $1 in
    --help | -h)
      echo -e "Script to auto rebuild NixOS system\n"
      echo -e "-n, --no-rebuild\n\tDon't rebuild system"
      echo -e "-u, --update\n\tUpdate flake.lock"
      echo -e "-e, --update-hw\n\tUpdate hardware-configuration.nix"
      echo -e "-c, --clean\n\tOptimise cache and garbage collect old builds"
      echo -e "    --hostname\n\tHostname to use for rebuild"
      exit 0
      ;;
    --update | -u)
      UPDATE="true"
      shift # past argument
      ;;
    --update-hw | -e)
      UPDATE_HW="true"
      shift # past argument
      ;;
    --no-rebuild | -n)
      REBUILD="false"
      shift # past argument
      ;;
    --clean | -c)
      CLEANUP="true"
      shift # past argument
      ;;
    --iso | -i)
      ISO="true"
      shift # past argument
      ;;
    --hostname)
      shift # past argument
      HOSTNAME="$1"
      shift
      ;;
    *)
      echo "erm what the sigma is $1, exiting"
      exit 1
      ;;
  esac
done

# catch unset hostname
if [[ -z "$HOSTNAME" || "$HOSTNAME" == "nixos" ]]; then
  echo "HOSTNAME unset or 'nixos', use --hostname <host>"
  exit 1
fi

NIXOS_DIRECTORY="$HOME/.dotfiles/nixos"

if [[ "$ISO" == "true" ]]; then
  # attempt to build, if successful, attempt to burn to disk
  nix build .#nixosConfigurations.live-iso.config.system.build.isoImage --out-link nix-iso
  caligula burn --compression none --hash skip nix-iso/iso/*.iso
  exit 0
fi

if [[ "$UPDATE" == "true" ]]; then
  echo "UPDATING FLAKE..."
  nix flake update
  echo "DONE UPDATING"
fi

if [[ "$UPDATE_HW" == "true" ]]; then
  echo "UPDATING HARDWARE CONFIG..."
  # regenerate HW config and template config, rm template config
  sudo nixos-generate-config --dir "$NIXOS_DIRECTORY/hosts/$HOSTNAME"
  sudo rm "$HOME/.dotfiles/nixos/hosts/$HOSTNAME/configuration.nix"
  echo "DONE UPDATING HARDWARE CONFIG"
fi

if [[ "$REBUILD" == "true" ]]; then
  echo "REBUILDING..."
  # basic rebuild
  # `#$HOSTNAME` will return "#orion" which is intended
  sudo nixos-rebuild switch --flake "$NIXOS_DIRECTORY/#$HOSTNAME"
  echo "DONE REBUILDING"
else
  echo "DRY RUN BUILD..."
  sudo nixos-rebuild dry-build --flake "$NIXOS_DIRECTORY/#$HOSTNAME"
  echo "DONE WITH DRY BUILD"
fi

if [[ "$CLEANUP" == "true" ]]; then
  echo "CLEANING UP..."
  nix-store --optimise
  nix-store --gc --print-dead
  echo "DONE CLEANING UP"
fi

