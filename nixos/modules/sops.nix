{ config, lib, pkgs, ... }:

let
  cfg = config.custom.secrets;
in
{
  options.custom.secrets = {
    enable = lib.mkEnableOption "Enable sops/age for secrets management";
    keyFile = lib.mkOption {
      type = lib.types.path;
      # TODO: this default is ugly but systems would need to migrate to a new default
      default = "/home/cwatson/.config/sops/age/keys.txt";
      description = "Path to age key file";
    };
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
        keyFile = cfg.keyFile;
        generateKey = true;
      };
    };
  };
}

