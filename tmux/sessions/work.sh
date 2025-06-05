#!/usr/bin/env bash
# scipt to open commonly used work files

SESH="anduril"

tmux has-session -t "$SESH" 2>/dev/null

if [ $? != 0 ]; then
  window="idx"
  tmux new-session  -d -s "$SESH" -n "$window"
  tmux split-window -t "$SESH":"$window".1 -h
  tmux split-window -t "$SESH":"$window".1 -v
  tmux send-keys    -t "$SESH":"$window".1 "cd ~/work/personal-logs; hx weekly-log.md" C-m
  tmux send-keys    -t "$SESH":"$window".2 "cd ~/work/personal-logs; gsll" C-m
  tmux send-keys    -t "$SESH":"$window".3 "cd ~/work/personal-logs/notes; hx useful_commands.md reference.md" C-m
  tmux resize-pane  -t "$SESH":"$window".1 -y "66%"
  tmux select-pane  -t "$SESH":"$window".1

  window="btop"
  tmux new-window   -t "$SESH" -n "$window"
  tmux move-window  -s "$SESH:$window" -t "$SESH":0
  tmux send-keys    -t "$SESH:$window" "btop" C-m

  window="apps"
  tmux new-window   -t "$SESH" -n "$window"
  tmux send-keys    -t "$SESH":"$window" "cdw; sudo ./apt+snap-update-upgrade.sh; ../sources/update_sources.sh" C-m

  window="croc-hc"
  tmux new-window   -t "$SESH" -n "$window"
  tmux send-keys    -t "$SESH":"$window" "cdw; ./health-checks/croc.sh" C-m

  window="talos-hc"
  tmux new-window   -t "$SESH" -n "$window"
  tmux send-keys    -t "$SESH":"$window" "cdw; ./health-checks/talos.sh" C-m

  # new window
  tmux new-window   -t "$SESH"
  tmux send-keys    -t "$SESH":3 "cdw" C-m
fi

# attempt to switch clients, if fails attach
tmux switch-client -t "$SESH" || tmux attach-session -t "$SESH"
