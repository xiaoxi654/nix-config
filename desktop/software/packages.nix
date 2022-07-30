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
    curl
    screen
    htop
    nix-top
    git
    tdesktop
    google-chrome
  ];
}
