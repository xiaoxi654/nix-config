{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  
  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-extra
    noto-fonts-emoji
  ];

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
