{ config, pkgs, inputs, pkgs-unstable, ... }:

{
  environment.systemPackages = (with pkgs; [
    helix
    # LSPs for helix
    # languages
    bash-language-server                    # bash... duh
    python312Packages.python-lsp-server     # python
    rust-analyzer                           # rust
    gopls                                   # go
    # configs
    nil                                     # nix
    yaml-language-server                    # yaml
    # misc
    marksman                                # markdown
  ]);
}
