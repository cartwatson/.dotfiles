{ config, lib, pkgs, pkgs-unstable, ... }:

{
  imports = [
    # TODO: make dynamic
    # imports = lib.filesystem.listFilesRecursive ./.;
    ./common/fonts.nix
    ./common/gui.nix
    ./gnome
    ./users/cwatson.nix
    ./users/jgordon.nix
  ];
}
