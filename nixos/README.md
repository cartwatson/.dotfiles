# Pillar(s of Creation)

![pillars of creation imager from Hubble](https://upload.wikimedia.org/wikipedia/commons/b/b1/New_view_of_the_Pillars_of_Creation_%E2%80%94_infrared_Heic1501b.jpg)

## Description

Repo to contain all config files for my machines, mostly focused on `nixos/`
which creates all my NixOS machines.

Named `pillar` for the Pillars of Creation, which create celestial objects,
which all devices are named after.

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
] ++ (lib.lists.optionals config.pillar.services.OPTION.enable [ # only add OPTIONAL enabled
  package3
  package4
])) ++ (with pkgs-unstable; [
  package5
  package6
]);
```

## Promised LAN

- [why](https://notes.pault.ag/tpl/)
- [how](https://tpl.house/)

### context

- 3 multi-site homelabs
- 3 admins, one for each site, but up to 10ish users per site (not likely to hit that high but peak traffic)
- multi-site each homelab is at a different location

### goals

- file sharing
- game servers
- device access
- no specific performance requirements outside of hosting game servers

### existing hw/conn/etc

- commercial home routers (think NETGEAR AX160)
- standard personal ISP connections (about 500mbps down and 30-60 up)
- no existing infrastructure

### constraints

- ideal budget is free or we buy hardware, would like to avoid renting
- no preferred vendors
- would like it to be compatible with mulitple HW and SW combinations
