# NixOS Config

## Setup

- install NixOS
- clone this repo
- run `./install.sh`
- [module config](./modules/README.md)

## References

- [Vimjoyers Nix/Flakes](https://www.youtube.com/watch?v=a67Sv4Mbxmc)

## Useful Nix tidbits

Sections of nix code that I find myself copying all the time

### diff sources + option enabled

combine multiple sets of packages from diff sources + only include packages if option is enabled

```nix
packages = (with pkgs; [
  package1
  package2
] ++ (lib.lists.optionals config.custom.services.OPTION.enable [ # only add OPTIONAL enabled
  package3
  package4
])) ++ (with pkgs-unstable; [
  package5
  package6
]);
```

minimize, maximize
12 hour time
dock
sleep
change colors in terminal

