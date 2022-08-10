{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    google-chrome
    neofetch
    tdesktop
    element-desktop
    teamspeak_client
    rnix-lsp
    osu-lazer
    polymc
    nur.repos.linyinfeng.icalingua-plus-plus
    nur.repos.linyinfeng.wemeet
  ];
}
