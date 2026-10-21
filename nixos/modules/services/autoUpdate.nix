{ config, lib, ... }:

let
  cfg = config.pillar.services.autoUpgrade;

  # custom mod because nix's builtin doesn't behave like python's
  mod = a: b: let r = a - (b * (builtins.div a b)); in if r < 0 then r + b else r;
  modifyTime =
    time: delta:
    let
      pad = x: lib.strings.fixedWidthNumber 2 x;
      minSinceMidnight = mod
        (
          (lib.toIntBase10 (builtins.elemAt (builtins.split ":" time) 0) * 60
          +
          lib.toIntBase10 (builtins.elemAt (builtins.split ":" time) 2)
        ) + delta)
        1440;
    in
    pad (minSinceMidnight / 60) + ":" + pad (mod minSinceMidnight 60);

  lowerTime = time: modifyTime time (-1);
  upperTime = time: modifyTime time (60);
in
{
  options.pillar.services.autoUpgrade= {
    enable = lib.mkEnableOption "";
    time = {
      enable = lib.mkEnableOption "auto updating";
      updateTime = lib.mkOption {
        type = lib.types.strMatching "[0-9]{2}:[0-9]{2}";
        default = "01:00";
        description = "Time to update, device may reboot within 1hr of provided time";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    system.autoUpgrade = lib.mkIf cfg.autoUpdate.enable {
      enable = true;
      upgrade = false; # don't pull in updates not in flake
      persistent = true; # if powered down during window. Upgrade when back online
      dates = "*-*-* ${cfg.autoUpdate.updateTime}:00";
      flake = "github:cartwatson/.dotfiles?dir=nixos";

      allowReboot = true; # Reboots ONLY if the kernel/boot loader changes
      rebootWindow.lower = lowerTime cfg.autoUpdate.updateTime;
      rebootWindow.upper = upperTime cfg.autoUpdate.updateTime;
    };
  };
}


