# Pillar

## Description

Repo to contain all config files for my machines, mostly focused on `nixos/` which creates all my NixOS machines.

Named `pillar` for the Pillars of Creation, which create celestial objects (which all devices are named after).

## Setup

- install NixOS
- clone this repo
- run `./install.sh`
- [module config](./modules/README.md)

## Common Patterns

### diff sources + option enabled

Combine multiple sets of packages from diff sources + only include packages if option is enabled

```nix
packages = (with pkgs; [
  package1
  package2
] ++ (lib.lists.optionals config.pillar.services.OPTION.enable [ # only add if OPTION enabled
  package3
  package4
])) ++ (with pkgs-unstable; [
  package5
  package6
]);
```

## REPL Help

- to import lib `lib = (import <nixpkgs> {}).lib;`

## Future work

- server
  - jungle.jjwatson.dev (shuffling always on* music player of jungle music)
  - jellyfin
  - restic server (repos for FAN users)
