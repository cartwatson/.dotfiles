{ config, lib, pkgs, ... }:

let
  cfg = config.custom.services.tailscale;
in
{
  options.custom.services.tailscale = {
    enable = lib.mkEnableOption "Enable tailscale";
    ssh.enable = lib.mkEnableOption "Enable ssh over tailscale (requires authKeyFile to be set)";
    exit-node.enable = lib.mkEnableOption "Advertise machine as exit node (requires authKeyFile to be set)";
    authKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to auth file";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.ssh.enable -> (cfg.authKeyFile != null);
        message = "ssh.enable requires a valid authKeyFile";
      }
      {
        assertion = cfg.exit-node.enable -> (cfg.authKeyFile != null);
        message = "exit-node.enable requires a valid authKeyFile";
      }
    ];

    environment.systemPackages = with pkgs; [
      tailscale
    ];

    # enable systemd service
    services.tailscale = {
      enable = true;
      interfaceName = "oort";
      openFirewall = true;
      authKeyFile = cfg.authKeyFile;

      extraUpFlags = if cfg.ssh.enable then [ "--ssh" ] else [ ];
      extraSetFlags = if cfg.exit-node.enable then [ "--advertise-exit-node" ] else [ ];
    };
  };
}
