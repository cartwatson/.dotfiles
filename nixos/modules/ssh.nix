{ config, lib, pkgs, pkgs-unstable, ... }:

let
  baseCfg = config.custom.services;
  cfg = baseCfg.ssh;
in
{
  options.custom.services.ssh = {
    enable = lib.mkEnableOption "Enable ssh access.";

    port = lib.mkOption {
      type = lib.types.port;
      default = 22;
      description = "Port for the SSH server and related services/protections.";
    };

    fail2ban = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "enable fail2ban for ssh";
    };

    endlessh = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "enable fail2ban for ssh";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable  {
      services.openssh = {
        enable = true;
        ports = [ cfg.port ];
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
          AllowUsers = null;  # Allows all users unless specified
          UseDns = true;
          X11Forwarding = false;
          PermitRootLogin = "no";
        };
      };
    })

    (lib.mkIf cfg.fail2ban {
      services.fail2ban = {
        enable = true;
        jails.sshd = ''
          enabled = true
          port = ${toString cfg.port}
          filter = sshd
          logpath = /var/log/auth.log
          maxretry = 3
        '';
      };
    })

    (lib.mkIf cfg.endlessh {
      services.endlessh = {
        enable = true;
        port = cfg.port;
        openFirewall = true;
      };
    })
  ];
}
