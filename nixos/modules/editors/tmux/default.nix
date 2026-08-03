{ config, lib, pkgs, ... }:

let
  cfg = config.pillar.services.tmux;
  plugins = import ./plugins.nix { inherit pkgs; };
  homedir = "/home/${cfg.user}";
  basedir = "${homedir}/.dotfiles";
in
{
  options.pillar.services.tmux = {
    enable = lib.mkEnableOption "Enable tmux and plugins system wide.";
    user = lib.mkOption {
      type = lib.types.str;
      default = "cwatson";
      description = "Which user `tmux.conf` should symlink to.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      # https://www.freedesktop.org/software/systemd/man/latest/tmpfiles.d.html
      # L+ /symlink/to/[re]create - - - - symlink/target/path
      "L+ ${homedir}/.tmux.conf   - - - - ${basedir}/nixos/modules/editors/tmux/tmux.conf"
    ];

    programs.tmux = {
      enable = true;
      plugins = plugins;
      newSession = true;
      # maybe do this in the future but the symlinking makes it easy for now
      # extraConfig = builtins.readFile ./tmux.conf;
    };

    environment.systemPackages = (with pkgs; [
      xclip # needed for clipboard functionality
    ]);
  };
}

