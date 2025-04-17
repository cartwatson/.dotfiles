#!/usr/bin/env bash
# scipt to open IDE like env in existing tmux from current or specified folder

function open_ide() {
  file_path=$1
  cd $file_path > /dev/null

  # get curr/provided dir for window name (remove '.' for ease)
  window=$(pwd | awk -F / '{print $NF}' | sed 's/\.//') || window="IDE"

  # exit if session already exists
  if [ $(tmux list-windows -F "#{window_name}" | grep -xc "$window") -gt 0 ]; then
    echo "switching to '$window' window..."
    tmux switch -t "$SESH":"$window"
    exit
  fi

  tmux new-window -n "$window"

  tmux split-window -t "$SESH":"$window".1 -h
  tmux split-window -t "$SESH":"$window".1 -v

  # auto open nix develop if available
  if [ -f ./shell.nix ]; then
    tmux send-keys -t "$SESH":"$window".1 "nix develop" C-m
  fi

  tmux send-keys -t "$SESH":"$window".2 "clear; gs" C-m
  tmux send-keys -t "$SESH":"$window".3 "hx ." C-m

  tmux select-pane -t "$SESH":"$window".3

  cd - > /dev/null
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

