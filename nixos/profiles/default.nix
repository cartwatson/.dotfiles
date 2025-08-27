{ config, lib, pkgs, pkgs-unstable, ... }:

{
  imports = [
    ./common/fonts.nix
    ./common/gui.nix
    ./gnome
    ./users/cwatson.nix
    ./users/jgordon.nix
  ];
}
