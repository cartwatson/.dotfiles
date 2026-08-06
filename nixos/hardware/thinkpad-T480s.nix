
{ lib, config, ... }:

let
  cfg = config.pillar.hardware.thinkpad-T480s;
in
{
  options.pillar.hardware.thinkpad-T480s = {
    enable = lib.mkEnableOption "Enable Thinkpad T480s config.";
  };

  config = lib.mkIf cfg.enable {
    services = {
      # enable updating firmware
      #   run the following occasionally
      #   `fwupdmgr refresh`
      #   `fwupdmgr update`
      fwupd.enable = true;

      tlp = {
        enable = true;
        settings = {
          # battery thresholds
          START_CHARGE_THRESH_BAT0 = 75;
          STOP_CHARGE_THRESH_BAT0 = 100;
          # powersave when on BAT, go ham when plugged in
          # CPU_SCALING_GOVERNOR_ON_AC = "performance";
          # CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
          # CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        };
      };

      # disable gnome power daemon
      power-profiles-daemon.enable = false;
    };
  };
}
