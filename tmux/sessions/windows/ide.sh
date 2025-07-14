#!/usr/bin/env bash
# scipt to open IDE like env in existing tmux from current or specified folder
# INSTRUCTIONS: navigate to dir to open ide in, run ide, profit

function open_ide() {
  file_path="$1"

  curr_window_num=$(tmux display-message -p -F '#{window_index}')
  echo "curr_window_num: $curr_window_num"

  # get curr/provided dir for window name (remove '.' for ease)
  window=$(pwd | awk -F / '{print $NF}' | sed 's/\.//') || window="IDE"

  # exit if session already exists
  if [ $(tmux list-windows -F "#{window_name}" | grep -xc "$window") -gt 0 ]; then
    echo "switching to '$window' window..."
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
  tmux resize-pane -t "$SESH":"$window".3 -x 65%
  tmux select-pane -t "$SESH":"$window".3
  tmux kill-window -t "$SESH:$curr_window_num"
  tmux move-window -t "$SESH" -r
}

if [ -z $TMUX ]; then
  # not in session
  echo "bro get in a session"
  exit 1
fi

file_path=$1
if [ -z $file_path ]; then
  file_path=$(pwd)
fi
open_ide $file_path

