{ pkgs, ... }:

{
  home.packages = with pkgs; [
    google-chrome
    neofetch
    tdesktop
    element-desktop
    teamspeak_client
    rnix-lsp
    osu-lazer
  ];
}
