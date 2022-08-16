{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    google-chrome
    neofetch
    tdesktop
    element-desktop
    discord
    teamspeak_client
    rnix-lsp
    polymc
    osu-lazer-appimage
    nur.repos.linyinfeng.icalingua-plus-plus
    nur.repos.linyinfeng.wemeet
  ];
}
