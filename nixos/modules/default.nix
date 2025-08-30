{ config, lib, pkgs, pkgs-unstable, ... }:

{
  imports = [
    ./docker.nix
    ./gaming.nix
    ./helix.nix
    ./tailscale.nix
  ];
}
