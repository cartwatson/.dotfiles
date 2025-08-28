{ config, lib, pkgs, pkgs-unstable, ... }:

{
  imports = [
    ./common
    ./common/fonts.nix
    ./common/gui.nix
    ./gnome
    ./users/cwatson.nix
    ./users/jgordon.nix
  ];
}
