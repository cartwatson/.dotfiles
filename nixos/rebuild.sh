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
      echo -e "-i, --iso\n\tCreate a bootable ISO"
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

NIXOS_DIRECTORY="$HOME/.dotfiles/nixos"

if [[ "$ISO" == "true" ]]; then
  # attempt to build, if successful, attempt to burn to disk
  nix build .#nixosConfigurations.live-iso.config.system.build.isoImage --out-link nix-iso
  echo ""
  echo "=== BURNING ISO ==="
  echo ""
  caligula burn --compression none --hash skip nix-iso/iso/*.iso
  echo ""
  echo "=== BOOT ISO ON DEVICE... ==="
  read -p "waiting... press enter when complete"
  echo ""

  # get new host info
  read -p "New machine's hostname: " TARGET_HOSTNAME
  read -p "New machine's IP address: " TARGET_IP

  # scaffold host config from template if it doesn't exist
  if [ ! -d "$NIXOS_DIRECTORY/hosts/$TARGET_HOSTNAME" ]; then
    echo "Creating host config from template..."
    mkdir -p "$NIXOS_DIRECTORY/hosts/$TARGET_HOSTNAME"
    cp "$NIXOS_DIRECTORY/lib/host-template.nix" "$NIXOS_DIRECTORY/hosts/$TARGET_HOSTNAME/default.nix"
  fi

  # ensure hardware config exists before attempting nixos-anywhere
  if [ ! -f "$NIXOS_DIRECTORY/hosts/$TARGET_HOSTNAME/hardware-configuration.nix" ]; then
    echo ""
    echo "In another terminal:"
    echo "  1. Get the hardware config from the target:"
    echo "       ssh root@$TARGET_IP -- nixos-generate-config --show-hardware-config > hosts/$TARGET_HOSTNAME/hardware-configuration.nix"
    echo "  2. Edit hosts/$TARGET_HOSTNAME/default.nix (set disk, enable profiles)"
    echo ""
    read -p "waiting... press enter when complete"

    # strip fileSystems and swapDevices — disko manages those
    sed -i '/^\s*fileSystems\./,/^\s*};$/d' "$NIXOS_DIRECTORY/hosts/$TARGET_HOSTNAME/hardware-configuration.nix"
    sed -i '/^\s*swapDevices\s*=/d' "$NIXOS_DIRECTORY/hosts/$TARGET_HOSTNAME/hardware-configuration.nix"
  fi

  nix run github:nix-community/nixos-anywhere -- --flake "$NIXOS_DIRECTORY"#"$TARGET_HOSTNAME" root@"$TARGET_IP"
  exit 0
fi

if [[ "$UPDATE" == "true" ]]; then
  echo "UPDATING FLAKE..."
  nix flake update
  echo "DONE UPDATING"
fi

# catch unset hostname
if [[ -z "$HOSTNAME" || "$HOSTNAME" == "nixos" ]]; then
  echo "HOSTNAME unset or 'nixos', use --hostname <host>"
  exit 1
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

