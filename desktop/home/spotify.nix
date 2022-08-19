{ pkgs, ... }:

{
  services.spotifyd = {
    enable = true;
    package = ( pkgs.spotifyd.override { withKeyring = true; });
    settings = {
      global = {
        username = "xiaoxi654@outlook.com";
        use_keyring = true;
        device_name = "Xiaoxi654-NixOS";
        autoplay = true;
      };
    };
  };
  home.file.".config/spotify-tui/config.yml" = {
    text = ''
      theme:
        playbar_progress_text: Blue
      behavior:
        volume_increment: 5
    '';
  };
}
