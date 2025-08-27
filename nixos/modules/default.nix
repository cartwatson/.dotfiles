{ config, lib, pkgs, pkgs-unstable, ... }:

{
  imports = [
    # TODO: make dynamic
    ./helix.nix
    ./docker.nix
    ./gaming.nix
    ./tailscale.nix
  ];
}
