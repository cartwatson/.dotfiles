{ ... }:

{
  imports = [
    ./docker.nix
    ./gaming.nix
    ./helix.nix
    ./tailscale.nix
    ./ssh.nix
    ./glance.nix
    ./caddy.nix
    ./minecraft
  ];
}
