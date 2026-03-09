#!/usr/bin/env bash
# Save current window's pane layout to /tmp for later restoration

session=$(tmux display-message -p '#{session_name}')
window=$(tmux display-message -p '#{window_index}')
layout=$(tmux display-message -p '#{window_layout}')
window_name=$(tmux display-message -p '#{window_name}')

outfile="/tmp/tmux-layout-${session}-${window}"

echo "$layout" > "$outfile"
echo "$window_name" >> "$outfile"

# Save per-pane info: pane_index|pane_current_path|pane_current_command
tmux list-panes -t "${session}:${window}" \
  -F '#{pane_index}|#{pane_current_path}|#{pane_current_command}' >> "$outfile"

tmux display-message "Layout saved (${num_panes} panes -> ${outfile})"
