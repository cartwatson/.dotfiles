#!/usr/bin/env bash
# scipt to open commonly used personal files

SESH="personal"

tmux has-session -t "$SESH" 2>/dev/null

if [ $? != 0 ]; then
  window="idx"
  tmux new-session   -d -s "$SESH" -n "$window"
  tmux split-window  -t "$SESH:$window".1 -h
  tmux send-keys     -t "$SESH:$window".1 "cds" C-m
  tmux send-keys     -t "$SESH:$window".2 "cds; hx" C-m
  tmux select-pane   -t "$SESH:$window".1

  window="dotfiles"
  tmux new-window    -t "$SESH" -n "$window"
  tmux send-keys     -t "$SESH:$window".1 "cd $HOME/.dotfiles" C-m
  tmux split-window  -t "$SESH:$window".1 -h -c "$HOME/.dotfiles"
  tmux split-window  -t "$SESH:$window".1 -v -c "$HOME/.dotfiles"
  tmux send-keys     -t "$SESH:$window".2
  tmux send-keys     -t "$SESH:$window".3 "hx ." C-m
  tmux select-pane   -t "$SESH:$window".3

  # NOTE: this assumes that the machine this is running on is a nix machine but lucky for me I only run nix machines :)
  if [[ -d ~/.dotfiles/nixos/hosts/$HOSTNAME ]]; then
    window="proxmox"
    tmux new-window  -t "$SESH" -n "$window"
    tmux send-keys   -t "$SESH:$window" "cd ~/personal/proxmox; gsll" C-m
  fi

  # new window
  tmux new-window -t "$SESH"
fi

# attempt to switch clients, if fails attach
tmux switch-client -t "$SESH" || tmux attach-session -t "$SESH"
