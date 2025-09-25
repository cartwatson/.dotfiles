{ ... }:

{
  imports = [
    ./sops.nix

    ./authelia.nix
    ./caddy.nix
    ./ddclient.nix
    ./docker.nix
    ./gaming.nix
    ./helix.nix
    ./lldap.nix
    ./ssh.nix
    ./tailscale.nix

    ./minecraft
    ./glance
  ];
}
