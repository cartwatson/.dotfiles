{ ... }:

{
  imports = [
    ./docker.nix
    ./gaming.nix
    ./helix.nix
    ./tailscale.nix
    ./ssh.nix
    ./caddy.nix

    ./minecraft
    ./glance
  ];
}
