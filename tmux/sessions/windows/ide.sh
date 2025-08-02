#!/usr/bin/env bash
# scipt to open IDE like env in existing tmux from current or specified folder
# INSTRUCTIONS: navigate to dir to open ide in, run ide, profit

function open_ide() {
  file_path=$(pwd)

  curr_window_num=$(tmux display-message -p -F '#{window_index}')

  # get curr/provided dir for window name (remove '.' for ease)
  window=$(echo "$file_path" | awk -F / '{print $NF}' | sed 's/\.//')

  # exit if session already exists
  if [ "$(tmux list-windows -F "#{window_name}" | grep -xc "$window")" -gt 0 ]; then
    tmux switch -t "$SESH":"$window"
    exit
  fi

  # create new window + panes
  tmux new-window -n "$window"
  tmux split-window -t "$SESH":"$window".1 -h
  tmux split-window -t "$SESH":"$window".1 -v

  # init panes with default commands
  # auto open `nix develop` if available
  if [ -f ./shell.nix ]; then
    tmux send-keys -t "$SESH":"$window".1 "nix develop" C-m
  fi
  tmux send-keys -t "$SESH":"$window".2 "clear; gs" C-m
  tmux send-keys -t "$SESH":"$window".3 "hx ." C-m

  # configure + move panes & windows
  shuffle_number=99
  tmux move-window -s "$SESH:$curr_window_num" -t "$SESH:$shuffle_number"
  tmux move-window -s "$SESH:$window" -t "$SESH:$curr_window_num"
  tmux kill-window -t "$SESH:$shuffle_number" # NOTE: THIS KILLS THE SCRIPT
}

if [ -z "$TMUX" ]; then
  # not in session
  echo "bro get in a session"
  exit 1
fi

open_ide
