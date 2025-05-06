{ config, pkgs, lib, ... }:

{
  environment.systemPackages = (with pkgs; [
    gnome-terminal
  ]);

  programs.dconf = {
    enable = true;
    profiles.user.databases = [
      {
        lockAll = true; # prevents overriding
        settings = lib.fix (self: with lib.gvariant; {
          "org/gnome/terminal/legacy" = {
            theme-variant="system";
          };

          "org/gnome/terminal/legacy/keybindings" = {
            find="disabled";
            find-clear="disabled";
            find-next="disabled";
            find-previous="disabled";
            move-tab-left="disabled";
            move-tab-right="disabled";
            new-tab="disabled";
            new-window="disabled";
            next-tab="disabled";
            prev-tab="disabled";
          };

          "org/gnome/terminal/legacy/profiles:" = {
            default="3b9fdbfc-015a-4e63-aee1-ee9997c8d62a";
            list=["3b9fdbfc-015a-4e63-aee1-ee9997c8d62a"];
          };

          "org/gnome/terminal/legacy/profiles:/:3b9fdbfc-015a-4e63-aee1-ee9997c8d62a" = {
            background-color="rgb(29,32,33)";
            background-transparency-percent=0.0;
            bold-color-same-as-fg=true;
            bold-is-bright=true;
            cursor-colors-set=false;
            foreground-color="rgb(235,219,178)";
            highlight-colors-set=false;
            palette=["rgb(29,32,33)" "rgb(204,36,29)" "rgb(152,151,26)" "rgb(215,153,33)" "rgb(69,133,136)" "rgb(177,98,134)" "rgb(104,157,106)" "rgb(168,153,132)" "rgb(40,40,40)" "rgb(251,73,52)" "rgb(184,187,38)" "rgb(250,189,47)" "rgb(131,165,152)" "rgb(211,134,155)" "rgb(142,192,124)" "rgb(235,219,178)"];
            use-theme-colors=false;
            use-theme-transparency=true;
            use-transparent-background=false;
            visible-name="gruvbox";
          };
        });
      }
    ];
  };
}
