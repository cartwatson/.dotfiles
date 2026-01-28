{ config, lib, pkgs, ... }:

let
  cfg = config.custom.secrets;
in
{
  options.custom.secrets = {
    enable = lib.mkEnableOption "Enable sops/age for secrets management";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = (with pkgs; [
      sops
      age
    ]);

    sops = {
      defaultSopsFile = ../secrets/secrets.yaml;
      defaultSopsFormat = "yaml";

      age = {
        # TODO: make this dynamic somehow
        keyFile = "/home/cwatson/.config/sops/age/keys.txt";
        generateKey = true;
      };
    };
  };
}

