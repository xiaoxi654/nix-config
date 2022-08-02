{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    screen
    htop
    file
    rnix-lsp
    nix-top
  ];
}
