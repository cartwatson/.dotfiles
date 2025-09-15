{ config, lib, pkgs, ... }:

let
  baseCfg = config.custom.services;
  cfg = baseCfg.docker;
in
{
  options.custom.services.docker = {
    enable = lib.mkEnableOption "Enable Docker.";
  };

  config = lib.mkIf cfg.enable {
    # install docker
    environment.systemPackages = (with pkgs; [
      docker
      docker-client # CLI client
    ]);

    # settings for docker
    virtualisation.docker.enable = true;
    virtualisation.docker.rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };
}
