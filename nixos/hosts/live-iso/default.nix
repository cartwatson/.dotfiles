{ modulesPath, lib, pkgs, ... }:

{
  imports = [
    # TODO: change to gnome installer
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  environment.systemPackages = (with pkgs; [
    disko
    parted
  ]);
}
