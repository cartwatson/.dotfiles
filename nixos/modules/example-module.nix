{ pkgs, lib, ... }

{
  option1.enable = true;
  systemPackages = with pkgs; [
    neovim
  ];
}
