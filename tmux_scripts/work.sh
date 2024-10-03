#!/usr/bin/env bash
# scipt to open commonly used work files

SESH="work"

tmux has-session -t "$SESH" 2>/dev/null

if [ $? != 0 ]; then
  tmux new-session -d -s "$SESH" -n "idx-work"
  # tmux new-window -t "$SESH" -n "idx"
  tmux send-keys -t "$SESH":idx-work "cd ~/personal/index/work/logs/anduril; gsll" C-m

  tmux new-window -t "$SESH" -n "proj"
  tmux send-keys -t "$SESH":proj "cdw" C-m
fi

# attempt to switch clients, if fails attach
tmux switch-client -t "$SESH" || tmux attach-session -t "$SESH"
