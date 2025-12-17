{ config, modulesPath, lib, pkgs, pkgs-unstable, settings, ... }:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  custom = {
  };

  environment.systemPackages = (with pkgs; [
    disko
    parted
  ]);
}
