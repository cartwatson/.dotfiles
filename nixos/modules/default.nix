{ config, lib, pkgs, pkgs-unstable, ... }:

{
  imports = [
    # TODO: import everything
    ./docker.nix
    ./gaming.nix
    ./helix.nix
    ./tailscale.nix
    ./ssh.nix
    ./glance.nix
    ./caddy.nix
    ./wireguard.nix
  ];
}
