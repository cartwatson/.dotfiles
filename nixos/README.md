# NixOS Config

## Instructions

- ALWAYS `git add` (this will break the build if not done and I have not a clue why (and the error won't tell you that))
- rebuild: `sudo nixos-rebuild switch --flake ~/.dotfiles/nixos/hosts/#<hostname>`

## Setup

- install NixOS
- mv default config and hardware config to `~/.dotfiles/nixos/hosts`
- symbolic link both files back to `/etc/nixos/`

## References

- [Vimjoyers Nix/Flakes/HomeManger Guide](https://www.youtube.com/watch?v=a67Sv4Mbxmc)
- [Dan Baker Dotfiles](https://github.com/djacu/dotfiles-tweag/tree/main)

