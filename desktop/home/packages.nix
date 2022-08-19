{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    google-chrome
    neofetch
    tdesktop
    obs-studio
    element-desktop
    discord
    spotify-tui
    teamspeak_client
    rnix-lsp
    polymc
    osu-lazer-appimage
    nur.repos.linyinfeng.icalingua-plus-plus
    nur.repos.linyinfeng.wemeet
  ];
}
