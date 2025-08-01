#!/usr/bin/env bash
# sets gnome, helix, and tmux theme based on current gnome theme selection

set -e

function set_gnome() {
  swapto=$1

  echo "Setting gnome..."
  if ! gsettings set org.gnome.desktop.interface color-scheme "$swapto"; then
    echo "Unable to set gnome mode to $swapto\nExiting..."
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
  sed -i "s#$current#$swapto#g" "$HOME/.dotfiles/tmux/tmux.conf"

  # reload tmux
  tmux source "$HOME/.dotfiles/tmux/tmux.conf"
}

if [[ "$(gsettings get org.gnome.desktop.interface color-scheme)" == "'prefer-dark'" ]]; then
  echo "Setting Light Mode"
  set_gnome prefer-light
  set_helix gruvbox_dark_hard_custom gruvbox_light_hard_custom
  set_tmux gruvbox-dark-tmux.conf gruvbox-light-tmux.conf
else # currently light mode
  echo "Setting Dark Mode"
  set_gnome prefer-dark
  set_helix gruvbox_light_hard_custom gruvbox_dark_hard_custom
  set_tmux gruvbox-light-tmux.conf gruvbox-dark-tmux.conf
fi

echo "All done"
echo "Make sure to set the terminal theme manually"


