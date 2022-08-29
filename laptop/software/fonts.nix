{ pkgs, ... }:

{
  fonts = {
    fonts = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-extra
      noto-fonts-emoji
      sarasa-gothic
      wqy_zenhei
      jetbrains-mono
    ];
    fontconfig = {
      enable = true;
      hinting = {
        enable = true;
      };
      defaultFonts = {
        serif = [ "Noto Serif CJK SC" ];
        sansSerif = [ "Sarasa UI SC" "Noto Sans CJK SC" ];
        monospace = [ "Jetbrains Mono" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
