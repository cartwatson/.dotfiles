#!/usr/bin/env bash
# scipt to open IDE like env in existing tmux from current folder

function open_ide() {
  window="IDE"
  tmux new-window -n "$window"

  tmux split-window -t "$SESH":"$window".1 -h
  # tmux split-window -t "$SESH":"$window".2 -h
  tmux split-window -t "$SESH":"$window".2 -v

  tmux send-keys -t "$SESH":"$window".1 "hx ." C-m
  tmux send-keys -t "$SESH":"$window".3 "clear; gs" C-m

  tmux select-pane -t "$SESH":"$window".1
}

if [ -z $TMUX ]; then
  # not in session
  echo "bro get in a session"
  exit 1
fi

open_ide
