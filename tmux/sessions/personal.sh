#!/usr/bin/env bash
# scipt to open commonly used personal files

SESH="personal"

tmux has-session -t "$SESH" 2>/dev/null

if [ $? != 0 ]; then
  window="idx"
  tmux new-session -d -s "$SESH" -n "$window"
  tmux split-window -t "$SESH":"$window".1 -h
  tmux send-keys -t "$SESH":"$window".1 "cds" C-m
  tmux send-keys -t "$SESH":"$window".2 "cds; hx" C-m
  tmux select-pane -t "$SESH":"$window".1

  tmux new-window -t "$SESH" -n "dotfiles"
  tmux send-keys -t "$SESH":dotfiles.1 "cd $HOME/.dotfiles" C-m
  tmux split-window -t "$SESH":dotfiles.1 -h -c "$HOME/.dotfiles"
  tmux split-window -t "$SESH":dotfiles.1 -v -c "$HOME/.dotfiles"
  tmux send-keys -t "$SESH":dotfiles.2
  tmux send-keys -t "$SESH":dotfiles.3 "hx ." C-m
  tmux select-pane -t "$SESH":"dotfiles".3

  # NOTE: this assumes that the machine this is running on is a nix machine but lucky for me I only run nix machines :)
  if [[ -d ~/.dotfiles/nixos/hosts/$HOSTNAME ]]; then
    tmux new-window -t "$SESH" -n "proxmox"
    tmux send-keys -t "$SESH":proxmox "cd ~/personal/proxmox; gsll" C-m
  fi

  tmux new-window -t "$SESH" -n "temp"
  tmux send-keys -t "$SESH":temp "cdm" C-m
fi

# attempt to switch clients, if fails attach
tmux switch-client -t "$SESH" || tmux attach-session -t "$SESH"
