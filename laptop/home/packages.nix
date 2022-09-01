{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    neofetch
    rclone
    tdesktop
    obs-studio
    element-desktop
    discord
    spotify-tui
    teamspeak_client
    jetbrains.idea-ultimate
    rnix-lsp
    polymc
    lutris
    osu-lazer-appimage
    nur.repos.linyinfeng.icalingua-plus-plus
    nur.repos.linyinfeng.wemeet
  ];
  programs.chromium = {
    enable = true;
    package = pkgs.google-chrome;
  };
}
