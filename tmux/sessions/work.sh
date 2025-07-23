#!/usr/bin/env bash
# scipt to open commonly used work files

SESH="anduril"

tmux has-session -t "$SESH" 2>/dev/null

if [ $? != 0 ]; then
  window="idx"
  tmux new-session   -d -s "$SESH" -n "$window" -c "$HOME/work/idx"
  tmux split-window  -t "$SESH:$window".1 -h    -c "$HOME/work/idx/notes"
  tmux send-keys     -t "$SESH:$window".1 "hx daily-log.md notes/personal-meeting-notes.md" C-m
  tmux send-keys     -t "$SESH:$window".2 "hx useful_commands.md reference.md" C-m

  window="btop"
  tmux new-window    -t "$SESH" -n "$window"
  tmux move-window   -s "$SESH:$window" -t "$SESH":0
  tmux send-keys     -t "$SESH:$window" "btop" C-m

  window="apps"
  tmux new-window    -t "$SESH" -n "$window" -c "$HOME/work"
  tmux send-keys     -t "$SESH:$window" "./apt+snap-update-upgrade.sh" C-m

  window="croc-hc"
  tmux new-window    -t "$SESH" -n "$window" -c "$HOME/work/scripts/health-checks"
  tmux send-keys     -t "$SESH:$window" "./crocodile-health-check.sh" C-m

  window="talos-hc"
  tmux new-window    -t "$SESH" -n "$window" -c "$HOME/work/scripts/health-checks"
  tmux send-keys     -t "$SESH:$window" "./talos-health-check.sh" C-m

  window="sentry-docs"
  tmux new-window    -t "$SESH" -n "$window" -c "$HOME/work/sentry-docs"
  tmux split-window  -t "$SESH:$window".1 -v -c "$HOME/work/sentry-docs"
  tmux split-window  -t "$SESH:$window".1 -h -c "$HOME/work/sentry-docs" -f -l 65%
  tmux send-keys     -t "$SESH:$window".1  "./scripts/deploy.sh" C-m
  tmux send-keys     -t "$SESH:$window".3  "hx ." C-m

  # new window
  tmux new-window    -t "$SESH"

  # select first window
  tmux select-pane   -t "$SESH:idx".1
fi

# attempt to switch clients, if fails attach
tmux switch-client   -t "$SESH" || tmux attach-session -t "$SESH"
