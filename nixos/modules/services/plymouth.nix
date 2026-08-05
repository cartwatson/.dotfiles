{ config, lib, pkgs, ... }:

let
  cfg = config.pillar.services.plymouth;
in
{
  options.pillar.services.plymouth = {
    enable = lib.mkEnableOption "Plymouth boot splash";
    theme = lib.mkOption {
      type = lib.types.str;
      default = "lone";
      description = "Plymouth theme name from adi1090x-plymouth-themes";
    };
  };

  config = lib.mkIf cfg.enable {
    boot.plymouth = {
      enable = true;
      theme = cfg.theme;
      themePackages = [
        (pkgs.adi1090x-plymouth-themes.override {
          selected_themes = [ cfg.theme ];
        })
      ];
    };

    boot.loader.timeout = lib.mkForce 0;
    boot.consoleLogLevel = 0;
    boot.initrd.verbose = false;
    boot.kernelParams = [
      "quiet"
      "splash"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_level=3"
      "boot.shell_on_fail"
    ];
  };
}
