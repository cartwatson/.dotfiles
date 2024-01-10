# .dotfiles

Collection of dotfiles for configs

Use `install.sh` to create symlinks to bashrc, bash_aliases, and vimrc and to generate machine_aliases, gitconfig

`install.sh` expects to be run from `~/.dotfiles` it should not be run from any other directory or cloned to a different location

## Setup Github Keys

1. `ssh-keygen -t ed25519 -C "your_email@example.com"`
    1. Make sure name of file is id_ed25519-\<hostsite\>
1. cat ~/.ssh/id_ed2559-\<hostsite\>
1. add to hostsite profile settings
1. key name on hostsite should be \<user\>@\<machine hostname\>

