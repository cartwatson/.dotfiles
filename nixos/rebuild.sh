#!/usr/bin/env bash

# exit if any command fails
set -eo pipefail

ISO="false"
UPDATE="false"
UPDATE_HW="false"
REBUILD="true"
CLEANUP="false"

MENU="true"

NIXOS_DIRECTORY="$HOME/.dotfiles/nixos"

function help_message() {
  echo -e "Script to auto rebuild NixOS system\n"
  echo -e "-n, --no-rebuild\n\tDon't rebuild system"
  echo -e "-u, --update\n\tUpdate flake.lock"
  echo -e "-e, --update-hw\n\tUpdate hardware-configuration.nix"
  echo -e "-c, --clean\n\tOptimise cache and garbage collect old builds"
  echo -e "-i, --iso\n\tCreate a bootable ISO"
  echo -e "    --hostname\n\tHostname to use for rebuild"
  exit 0
}

function generate_iso() {
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
}

function update_flake() {
  echo "UPDATING FLAKE..."
  nix flake update --flake $NIXOS_DIRECTORY
  if [[ ! $? ]]; then
    echo "UPDATE FAILED: run nix flake update from repo"
  else
    echo "DONE UPDATING"
  fi
  echo
}

function update_repo() {
  echo "UPDATING REPO..."
  git -C $NIXOS_DIRECTORY pull
  if [[ ! $? ]]; then
    echo "UPDATE FAILED: run git pull from repo"
  else
    echo "DONE UPDATING"
  fi
  echo
}

function update_hardware() {
  echo "UPDATING HARDWARE CONFIG..."
  # regenerate HW config and template config, rm template config
  sudo nixos-generate-config --dir "$NIXOS_DIRECTORY/hosts/$HOSTNAME"
  sudo rm "$HOME/.dotfiles/nixos/hosts/$HOSTNAME/configuration.nix"
  echo "DONE UPDATING HARDWARE CONFIG"
  echo
}

function cleanup() {
  echo "CLEANING UP..."
  nix-store --optimise
  nix-store --gc --print-dead
  nix-collect-garbage
  echo "DONE CLEANING UP"
  echo
}

function rebuild() {
  echo "REBUILDING..."
  # basic rebuild
  # `#$HOSTNAME` will return "#jupiter" which is intended
  sudo nixos-rebuild switch --flake "$NIXOS_DIRECTORY/#$HOSTNAME"
  if [[ ! $? ]]; then
    echo "REBUILD FAILED"
  else
    echo "DONE REBUILDING"
  fi
  echo
}

function rebuild_dry() {
  echo "DRY RUN BUILD..."
  sudo nixos-rebuild dry-build --flake "$NIXOS_DIRECTORY/#$HOSTNAME"
  if [[ ! $? ]]; then
    echo "DRY BULID FAILED"
  else
    echo "DONE WITH DRY BUILD"
  fi
  echo
  exit 0
}

while [[ $# -gt 0 ]]; do
  case $1 in
    --help | -h)
      help_message
      ;;
    --iso | -i)
      generate_iso
      MENU="false"
      ;;
    --update | -u)
      update_flake
      MENU="false"
      shift
      ;;
    --update-repo)
      update_repo
      MENU="false"
      shift
      ;;
    --update-hw | -e)
      update_hardware
      MENU="false"
      shift # past argument
      ;;
    --no-rebuild | -n)
      rebuild_dry
      ;;
    --clean | -c)
      cleanup
      MENU="false"
      shift # past argument
      ;;
    --hostname)
      shift # past argument
      HOSTNAME="$1"
      shift
      ;;
    *)
      echo "erm what the sigma is $1, exiting"
      echo
      help_message
      exit 1
      ;;
  esac
done

# catch unset hostname
if [[ -z "$HOSTNAME" || "$HOSTNAME" == "nixos" ]]; then
  echo "HOSTNAME is unset or is 'nixos', use pillar --hostname <host_name>"
  exit 1
fi

if [[ $MENU == "true" ]]; then
  echo "╻ ╻┏━╸╻  ┏━╸┏━┓┏┳┓┏━╸   ╺┳╸┏━┓
┃╻┃┣╸ ┃  ┃  ┃ ┃┃┃┃┣╸     ┃ ┃ ┃
┗┻┛┗━╸┗━╸┗━╸┗━┛╹ ╹┗━╸    ╹ ┗━┛
██████╗ ██╗██╗     ██╗      █████╗ ██████╗
██╔══██╗██║██║     ██║     ██╔══██╗██╔══██╗
██████╔╝██║██║     ██║     ███████║██████╔╝
██╔═══╝ ██║██║     ██║     ██╔══██║██╔══██╗
██║     ██║███████╗███████╗██║  ██║██║  ██║
╚═╝     ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝"

  if [[ $# -eq 0 ]]; then
    echo
    echo "Select an option:"
    echo "    1) Rebuild (enter)"
    echo "    2) Update Flake"
    echo "    3) Update Repo & Rebuild"
    echo "    4) Update HW Config"
    echo "    5) Clean System"
    echo "    6) Generate ISO"
    echo "    q) Exit"
    echo
    read -p "Make your selection [1-6]: " choice
    echo

    case $choice in
        1 | "") rebuild ;;
        2) update_flake ;;
        3) update_repo; rebuild ;;
        4) update_hardware ;;
        5) cleanup ;;
        6) generate_iso ;;
        *) echo "Exiting"; exit 0 ;;
    esac
  fi
fi

