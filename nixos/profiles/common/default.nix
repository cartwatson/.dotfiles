{ config, lib, pkgs, ... }:

{
  imports = [
    ./base.nix
  ];

  custom = {
    users.cwatson.enable = lib.mkDefault true;
    users.wwatson.enable = lib.mkDefault false;
    users.jgordon.enable = lib.mkDefault false;
  };
}
