SESH="work"

tmux has-session -t $SESH 2>/dev/null

if [ $? != 0 ]; then
  tmux new-session -d -s $SESH -n "proj1"
  # tmux new-window -t $SESH -n "idx"
  tmux send-keys -t $SESH:proj1 "cdw" C-m

  # tmux new-window -t $SESH -n "dotfiles"
  # tmux send-keys -t $SESH:dotfiles "cdd" C-m
fi

tmux attach-session -t $SESH
