{ pkgs, ... }:

{
  option1.enable = true;
  environment.systemPackages = with pkgs; [
    neovim
  ];
}
