{ config, lib, pkgs, pkgs-unstable, ... }:

let
  sshConfig = {
    services.openssh = {
      enable = true;
      ports = [ config.custom.services.ssh.port ];
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        AllowUsers = null;  # Allows all users unless specified
        UseDns = true;
        X11Forwarding = false;
        PermitRootLogin = "no";
      };
    };
  };

  fail2banConfig = {
    services.fail2ban = {
      enable = true;
      jails.sshd = ''
        enabled = true
        port = ${toString config.custom.services.ssh.port}
        filter = sshd
        logpath = /var/log/auth.log
        maxretry = 3
      '';
    };
  };

  endlesshConfig = {
    services.endlessh = {
      enable = true;
      port = config.custom.services.ssh.port;
      openFirewall = true;
    };
  };
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
    (lib.mkIf config.custom.services.ssh.enable   sshConfig)
    (lib.mkIf config.custom.services.ssh.fail2ban fail2banConfig)
    (lib.mkIf config.custom.services.ssh.endlessh endlesshConfig)
  ];
}
