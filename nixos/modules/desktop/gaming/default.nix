{ config, lib, pkgs, pkgs-unstable, ... }:

let
  cfg = config.custom.services.gaming;
in
{
  imports = [
    ./steam.nix
    ./minecraft.nix
  ];

  options.custom.services.gaming = {
    enable = lib.mkEnableOption "Enable Gaming.";
    openttd = lib.mkEnableOption "Install OpenTTD";
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.mkIf cfg.openttd {
        environment.systemPackages = (with pkgs-unstable; [
          openttd
        ]);
      })
    ]
  );
}
