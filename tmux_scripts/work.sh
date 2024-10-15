#!/usr/bin/env bash
# scipt to open commonly used work files

SESH="work"

tmux has-session -t "$SESH" 2>/dev/null

if [ $? != 0 ]; then
  tmux new-session -d -s "$SESH" -n "idx-work"
  # tmux new-window -t "$SESH" -n "idx"
  tmux send-keys -t "$SESH":idx-work "cd ~/work/personal-logs" C-m

  tmux new-window -t "$SESH" -n "apps"
  tmux send-keys -t "$SESH":apps "cdh" C-m

  tmux new-window -t "$SESH" -n "bash"
  tmux send-keys -t "$SESH":bash "cdw" C-m
fi

# attempt to switch clients, if fails attach
tmux switch-client -t "$SESH" || tmux attach-session -t "$SESH"
