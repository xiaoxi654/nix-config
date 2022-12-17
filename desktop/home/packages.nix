{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    # Tools
    neofetch
    rclone
    obs-studio
    wineWowPackages.staging
    winetricks
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
    prismlauncher       # Minecraft Launcher
    lutris
    gamescope
    mangohud            # Kinda like a tool?
    gamemode            # Yep
    osu-lazer-appimage  # OSU!Lazer
    yuzu-early-access   # NS Emulator
    # Others
    spotify-tui
    # NUR
    nur.repos.linyinfeng.icalingua-plus-plus
    nur.repos.linyinfeng.wemeet
  ];
  programs.chromium = {
    enable = true;
    package = pkgs.google-chrome;
  };
}
