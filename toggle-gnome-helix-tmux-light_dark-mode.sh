#!/usr/bin/env bash
# sets gnome, helix, and tmux theme based on current gnome theme selection
# on locked gnome systems. It will change tmux and helix themes

set -e

[ "$(gsettings get org.gnome.desktop.interface color-scheme)" = "'prefer-dark'" ]
switchToLightMode=$?

while [[ $# -gt 0 ]]; do
  case $1 in
    --dark | -d)
      switchToLightMode=0
      shift
      ;;
    --light | -l)
      switchToLightMode=1
      shift
      ;;
    *)
      echo "unknown arg: $1"
      exit 1
      ;;
  esac
done

function set_gnome() {
  swapto=$1

  echo "Setting gnome..."
  if ! gsettings set org.gnome.desktop.interface color-scheme "$swapto"; then
    echo -e "Unable to set gnome mode to $swapto\nExiting..."
    return 1
  fi
}

function set_helix() {
  current=$1
  swapto=$2

  echo "Setting Helix..."
  sed -i "s#$current#$swapto#g" "$HOME/.dotfiles/helix/config.toml"

  # reload helix
  pkill -USR1 hx
}

function set_tmux() {
  current=$1
  swapto=$2

  echo "Setting Tmux..."
  sed -i "s#$current#$swapto#g" "$HOME/.dotfiles/nixos/modules/editors/tmux/themes/design.conf"

  # reload tmux
  tmux source "$HOME/.tmux.conf"
}

if [ "$switchToLightMode" -eq "1" ]; then
  echo "Setting Light Mode"
  set_helix gruvbox_dark_hard gruvbox_light_hard
  set_tmux gruvbox-dark-tmux.conf gruvbox-light-tmux.conf
  set_gnome default
else
  echo "Setting Dark Mode"
  set_helix gruvbox_light_hard gruvbox_dark_hard
  set_tmux gruvbox-light-tmux.conf gruvbox-dark-tmux.conf
  set_gnome prefer-dark
fi

echo "All done"
echo "Make sure to set the terminal theme manually"

