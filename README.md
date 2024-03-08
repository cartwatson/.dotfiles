# .dotfiles

Collection of dotfiles for configs

## Usage

`install.sh` expects to be run from `~/.dotfiles` it should not be run from any other directory or cloned to a different location

## Setup Github Keys

1. run `install.sh` and respond `Y` to creating ssh-keys
1. add to hostsite profile settings
    - key name on hostsite should be \<user\>@\<machine hostname\>
1. test with `ssh git@github.com` or with the default user@hostname

## Resources for setup of LSPs for Helix

- [helix wiki](https://github.com/helix-editor/helix/wiki/How-to-install-the-default-language-servers#cc)
- [docs](https://docs.helix-editor.com/lang-support.html)
