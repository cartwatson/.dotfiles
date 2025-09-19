{ ... }:

{
  imports = [
    ./sops.nix

    ./caddy.nix
    ./ddclient.nix
    ./docker.nix
    ./gaming.nix
    ./helix.nix
    ./ssh.nix
    ./tailscale.nix

    ./minecraft
    ./glance
  ];
}
