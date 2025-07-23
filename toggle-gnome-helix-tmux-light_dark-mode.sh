#!/usr/bin/env bash
# sets helix and tmux theme based on current gnome theme selection
# TODO: toggle theme from gsettings directly

THEME=$(gsettings get org.gnome.desktop.interface color-scheme)

if [[ "$THEME" == "'prefer-dark'" ]]; then # currently dark mode
  echo "Setting Light Mode"

  echo "Setting gnome..."
  gsettings set org.gnome.desktop.interface color-scheme prefer-light

  echo "Setting Helix..."
  sed -i 's#theme = "gruvbox_dark_hard_custom"#theme = "gruvbox_light_hard_custom"#g' ~/.dotfiles/helix/config.toml
  # reload helix
  pkill -USR1 hx

  echo "Setting Tmux..."
  sed -i 's#source-file ~/.dotfiles/tmux/themes/gruvbox-dark-tmux.conf#source-file ~/.dotfiles/tmux/themes/gruvbox-light-tmux.conf#g' ~/.dotfiles/tmux/tmux.conf
  # reload tmux
  tmux source ~/.dotfiles/tmux/tmux.conf
else # currently light mode
  echo "Setting Dark Mode"

  echo "Setting gnome..."
  gsettings set org.gnome.desktop.interface color-scheme prefer-dark

  echo "Setting Helix..."
  sed -i 's#theme = "gruvbox_light_hard_custom"#theme = "gruvbox_dark_hard_custom"#g' ~/.dotfiles/helix/config.toml
  # reload helix
  pkill -USR1 hx

  echo "Setting Tmux..."
  sed -i 's#source-file ~/.dotfiles/tmux/themes/gruvbox-light-tmux.conf#source-file ~/.dotfiles/tmux/themes/gruvbox-dark-tmux.conf#g' ~/.dotfiles/tmux/tmux.conf
  # reload tmux
  tmux source ~/.dotfiles/tmux/tmux.conf
fi

echo "All done"
echo "Make sure to set the terminal theme manually"


