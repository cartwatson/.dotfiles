{ config, lib, pkgs, ... }:

let
  cfg = config.custom.services.printing;

  rongta58Driver = pkgs.callPackage ./rongta58/default.nix {};
in
{
  options.custom.services.printing = {
    enable = lib.mkEnableOption "Enable printing for the Rongta58 Thermal Printer";
    name = lib.mkOption {
      type = lib.types.str;
      default = "Rongta58-Thermal-Printer";
      description = "String for printer name, cannot include '#', '/' or ' '.";
    };
    ip = lib.mkOption {
      type = lib.types.str;
      default = "192.168.1.87";
      description = "Printer IP, expecting a valid IP (v4 or v6) address as a string. (WARN: does not verify if IP is valid)";
    };
  };

  config = lib.mkIf cfg.enable {
    services.printing = {
      enable = true;
      drivers = [
        rongta58Driver
      ];
    };

    hardware.printers = {
      ensureDefaultPrinter = cfg.name;
      ensurePrinters = [
        {
          name = cfg.name;
          location = "home";

          deviceUri = "socket://${cfg.ip}:9100";
          model = "Printer58.ppd";
        }
      ];
    };
  };
}

