#!/usr/bin/env bash

THEME=$(gsettings get org.gnome.desktop.interface color-scheme)

if [[ "$THEME" == "'prefer-dark'" ]]; then
  echo "Setting Dark Mode"

  echo "Setting Helix..."
  sed -i 's#theme = "gruvbox_light_hard_custom"#theme = "gruvbox_dark_hard_custom"#g' ~/.dotfiles/helix/config.toml
  # reload helix
  pkill -USR1 hx

  echo "Setting Tmux..."
  sed -i 's#source-file ~/.dotfiles/tmux/themes/gruvbox-light-tmux.conf#source-file ~/.dotfiles/tmux/themes/gruvbox-dark-tmux.conf#g' ~/.dotfiles/tmux/tmux.conf
  # reload tmux
  tmux source ~/.dotfiles/tmux/tmux.conf

  echo "All done"

else # LIGHT MODE
  echo "Setting Light Mode"

  echo "Setting Helix..."
  sed -i 's#theme = "gruvbox_dark_hard_custom"#theme = "gruvbox_light_hard_custom"#g' ~/.dotfiles/helix/config.toml
  # reload helix
  pkill -USR1 hx

  echo "Setting Tmux..."
  sed -i 's#source-file ~/.dotfiles/tmux/themes/gruvbox-dark-tmux.conf#source-file ~/.dotfiles/tmux/themes/gruvbox-light-tmux.conf#g' ~/.dotfiles/tmux/tmux.conf
  # reload tmux
  tmux source ~/.dotfiles/tmux/tmux.conf

  echo "All done"
fi


