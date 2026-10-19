{ config, lib, pkgs, ... }:

let
  cfg = config.pillar.services.gaming;
in
{
  options.pillar.services.gaming = {
    minecraft = lib.mkEnableOption "Install PrismLauncher for Minecraft";
  };

  config = lib.mkIf (cfg.enable && cfg.minecraft) {
    environment.systemPackages = (with pkgs; [
      # https://wiki.nixos.org/wiki/Prism_Launcher
      (prismlauncher.override {
        # Change Java runtimes available to Prism Launcher
        jdks = [
          jdk17 # ATM9
          jdk21 # 1.1X.X
          jdk25 # 26.X.X
        ];
      })
    ]);
  };
}

