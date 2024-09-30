#!/usr/bin/env bash
# scipt to open commonly used personal files

SESH="personal"

function open_tabs() {
  tmux send-keys -t "$SESH":idx "cds" C-m

  tmux new-window -t "$SESH" -n "dotfiles"
  tmux send-keys -t "$SESH":dotfiles "cdd" C-m

  tmux new-window -t "$SESH" -n "temp"
  tmux send-keys -t "$SESH":temp "cdm" C-m
}

tmux has-session -t "$SESH" 2>/dev/null

if [ $? != 0 ]; then
  # session doesn't exist
  tmux new-session -d -s "$SESH" -n "idx"
  # tmux new-window -t "$SESH" -n "idx" # session exists, window doesn't
  open_tabs
fi

if [ -n "$TMUX" ]; then
  tmux switch-client -t "$SESH"
else
  tmux attach-session -t "$SESH"
fi
