{ config, lib, pkgs, ... }:

let
  cfg = config.pillar.services.docker;
in
{
  options.pillar.services.docker = {
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
