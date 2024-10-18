#!/usr/bin/env bash
# scipt to open commonly used work files

SESH="anduril"

tmux has-session -t "$SESH" 2>/dev/null

if [ $? != 0 ]; then
  window="idx"
  tmux new-session -d -s "$SESH" -n "$window"
  tmux send-keys -t "$SESH":"$window" "cd ~/work/personal-logs" C-m
  tmux split-window -h
  tmux send-keys -t "$SESH":"$window".1 "hx daily-log.md" C-m
  tmux select-pane -t "$SESH":"$window".1
  tmux split-window -v
  tmux send-keys -t "$SESH":"$window".2 "cdw" C-m
  tmux send-keys -t "$SESH":"$window".3 "cd ~/work/personal-logs/notes; hx ." C-m
  tmux select-pane -t "$SESH":"$window".1

  window="apps"
  tmux new-window -t "$SESH" -n "$window"
  tmux send-keys -t "$SESH":"$window" "cdh" C-m

  tmux new-window -t "$SESH"
  tmux send-keys -t "$SESH":3 "cdw" C-m
fi

# attempt to switch clients, if fails attach
tmux switch-client -t "$SESH" || tmux attach-session -t "$SESH"
