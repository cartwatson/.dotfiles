{ config, lib, pkgs, ... }:

let
  cfg = config.pillar.services.ctf;
in
{
  options.pillar.services.ctf = {
    enable = lib.mkEnableOption "CTF tools for reverse engineering, pwn, crypto, and forensics";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # Reverse engineering
      ghidra
      cutter
      rizin

      # Binary exploitation
      gdb
      gdbserver
      checksec
      patchelf
      ropper
      one_gadget

      # Symbolic execution / constraint solving
      z3

      # Cryptography
      sage
      hashcat
      john

      # Forensics
      binwalk
      sleuthkit
      foremost
      exiftool
      yara

      # Web
      burpsuite
      mitmproxy

      # Mobile
      apktool
      jadx

      # Firmware / emulation
      qemu
      upx

      # Miscellaneous
      socat
      volatility3
      radamsa
    ];
  };
}
