{ pkgs, lib, config, ... }:

let
  cfg = config.custom.services.gnome;
in
{
  config = lib.mkIf cfg.terminal.enable {
    environment.gnome.excludePackages = (with pkgs; [
        gnome-console
    ]);

    environment.systemPackages = (with pkgs; [
      gnome-terminal
    ]);

    programs.dconf = lib.mkIf cfg.terminal.customize {
      enable = true;
      profiles.user.databases = [
        {
          lockAll = true; # prevents overriding
          settings = lib.fix (_self: with lib.gvariant; {
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
              list=["3b9fdbfc-015a-4e63-aee1-ee9997c8d62a" "869345bb-44f7-4591-a4dc-7faaf83458e2"];
            };

            "org/gnome/terminal/legacy/profiles:/:3b9fdbfc-015a-4e63-aee1-ee9997c8d62a" = {
              background-color="rgb(29,32,33)";
              background-transparency-percent=0.0;
              bold-color-same-as-fg=true;
              bold-is-bright=true;
              cursor-colors-set=false;
              foreground-color="rgb(235,219,178)";
              highlight-colors-set=false;
              palette=["rgb(28,28,28)" "rgb(204,36,29)" "rgb(152,151,26)" "rgb(215,153,33)" "rgb(69,133,136)" "rgb(177,98,134)" "rgb(104,157,106)" "rgb(168,153,132)" "rgb(40,40,40)" "rgb(251,73,52)" "rgb(184,187,38)" "rgb(250,189,47)" "rgb(131,165,152)" "rgb(211,134,155)" "rgb(142,192,124)" "rgb(235,219,178)"];
              use-theme-colors=false;
              use-theme-transparency=true;
              use-transparent-background=false;
              visible-name="gruvbox";
            };

            "org/gnome/terminal/legacy/profiles:/:869345bb-44f7-4591-a4dc-7faaf83458e2" = {
              background-color="rgb(255,255,221)";
              background-transparency-percent=0.0;
              bold-color-same-as-fg=true;
              bold-is-bright=false;
              foreground-color="rgb(0,0,0)";
              login-shell=false;
              palette=["rgb(46,52,54)" "rgb(204,0,0)" "rgb(78,154,6)" "rgb(196,160,0)" "rgb(52,101,164)" "rgb(117,80,123)" "rgb(6,152,154)" "rgb(211,215,207)" "rgb(85,87,83)" "rgb(239,41,41)" "rgb(138,226,52)" "rgb(252,233,79)" "rgb(114,159,207)" "rgb(173,127,168)" "rgb(52,226,226)" "rgb(238,238,236)"];
              use-custom-command=false;
              use-theme-colors=false;
              use-theme-transparency=false;
              use-transparent-background=false;
              visible-name="Outside";
            };
          });
        }
      ];
    };
  };
}
