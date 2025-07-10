#!/usr/bin/env bash
# scipt to open commonly used work files

SESH="anduril"

tmux has-session -t "$SESH" 2>/dev/null

if [ $? != 0 ]; then
  window="idx"
  tmux new-session   -d -s "$SESH" -n "$window"
  tmux split-window  -t "$SESH:$window".1 -h
  tmux send-keys     -t "$SESH:$window".1 "cd ~/work/idx; hx daily-log.md notes/personal-meeting-notes.md" C-m
  tmux send-keys     -t "$SESH:$window".2 "cd ~/work/idx/notes; hx useful_commands.md reference.md" C-m

  window="btop"
  tmux new-window    -t "$SESH" -n "$window"
  tmux move-window   -s "$SESH:$window" -t "$SESH":0
  tmux send-keys     -t "$SESH:$window" "btop" C-m

  window="apps"
  tmux new-window    -t "$SESH" -n "$window"
  tmux send-keys     -t "$SESH:$window" "cdw; sudo ./apt+snap-update-upgrade.sh; ../sources/update_sources.sh" C-m

  window="croc-hc"
  tmux new-window    -t "$SESH" -n "$window"
  tmux send-keys     -t "$SESH:$window" "cd $HOME/work/scripts/health-checks; ./crocodile-health-check.sh" C-m

  window="talos-hc"
  tmux new-window    -t "$SESH" -n "$window"
  tmux send-keys     -t "$SESH:$window" "cd $HOME/work/scripts/health-checks; ./talos-health-check.sh" C-m

  # new window
  tmux new-window    -t "$SESH"

  # select first window
  tmux select-pane   -t "$SESH:idx".1
fi

# attempt to switch clients, if fails attach
tmux switch-client   -t "$SESH" || tmux attach-session -t "$SESH"
