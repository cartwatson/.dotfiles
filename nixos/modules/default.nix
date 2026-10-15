{ ... }:

{
  imports = [
    ./desktop
    ./editors
    ./networking
    ./services

    ./data.nix
    ./sops.nix
  ];
}
