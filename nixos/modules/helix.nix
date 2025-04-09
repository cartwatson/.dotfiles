{ config, pkgs, lib, ... }:

{
  environment.systemPackages = (with pkgs; [
    helix
    # LSPs for helix
    nil                                     # nix
    marksman                                # markdown
    bash-language-server                    # bash... duh
    python312Packages.python-lsp-server     # python
    rust-analyzer                           # rust
    gopls                                   # go
  ]);
}
