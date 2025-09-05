{ config, lib, pkgs, pkgs-unstable, ... }:

{
  imports = [
    ./common
    ./common/fonts.nix
    ./gnome
    ./users/cwatson.nix
    ./users/jgordon.nix
  ];
}
