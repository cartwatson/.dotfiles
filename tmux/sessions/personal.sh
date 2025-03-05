#!/usr/bin/env bash
# scipt to open commonly used personal files

SESH="personal"

function open_tabs() {
  window="idx"
  tmux new-session -d -s "$SESH" -n "$window"
  tmux split-window -t "$SESH":"$window".1 -h
  tmux send-keys -t "$SESH":"$window".1 "cds; hx" C-m
  tmux send-keys -t "$SESH":"$window".2 "cds" C-m
  tmux select-pane -t "$SESH":"$window".1

  tmux new-window -t "$SESH" -n "dotfiles"
  tmux send-keys -t "$SESH":dotfiles "cdd" C-m

  # NOTE: this assumes that the machine this is running on is a nix machine but lucky for me I only run nix machines :)
  if [[ -d ~/.dotfiles/nixos/hosts/$(HOSTNAME) ]]; then
    tmux new-window -t "$SESH" -n "proxmox"
    tmux send-keys -t "$SESH":proxmox "cd ~/personal/proxmox; gsll" C-m
  fi

  tmux new-window -t "$SESH" -n "temp"
  tmux send-keys -t "$SESH":temp "cdm" C-m
}

tmux has-session -t "$SESH" 2>/dev/null

if [ $? != 0 ]; then
  # session doesn't exist
  tmux new-session -d -s "$SESH" -n "idx"
  open_tabs
fi

# attempt to switch clients, if fails attach
tmux switch-client -t "$SESH" || tmux attach-session -t "$SESH"
