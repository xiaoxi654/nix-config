{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    # Tools
    neofetch
    rclone
    obs-studio
    # IM/Voice Chat
    tdesktop            # Telegram
    element-desktop     # Matrix
    discord             # Discord
    mumble              # Mumble
    teamspeak_client    # Teamspeak3
    profanity           # XMPP
    # DEV/DOC
    jetbrains.idea-ultimate
    wpsoffice-cn
    rnix-lsp
    # Games
    polymc              # Minecraft Launcher
    lutris
    mangohud            # Kinda like a tool?
    gamemode            # Yep
    osu-lazer-appimage  # OSU!Lazer
    heroic-appimage     # EGL
    # Others
    spotify-tui
    # NUR
    nur.repos.xddxdd.dingtalk
    nur.repos.linyinfeng.icalingua-plus-plus
    nur.repos.linyinfeng.wemeet
  ];
  programs.chromium = {
    enable = true;
    package = pkgs.google-chrome;
  };
}
