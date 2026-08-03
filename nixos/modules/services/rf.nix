{ config, lib, pkgs, ... }:

let
  cfg = config.pillar.services.rf;
in
{
  options.pillar.services.rf = {
    enable = lib.mkEnableOption "RF/SDR tools for radio experimentation";
  };

  config = lib.mkIf cfg.enable {
    hardware.rtl-sdr.enable = true;

    environment.systemPackages = with pkgs; [
      # core SDR
      rtl-sdr
      gqrx
      sdrpp
      gnuradio

      # decoding and analysis
      rtl_433
      inspectrum
      urh
      multimon-ng

      # utilities
      sox
      audacity
    ];
  };
}
