{ pkgs, ... }:

{
  services = {
    xserver = {
      enable = true;
      libinput = {
        enable = true;
        mouse = {
          accelProfile = "flat";
        };
      };
      displayManager.sddm = {
        enable = true;
        theme = "${(pkgs.fetchFromGitHub {
          owner = "MarianArlt";
          repo = "sddm-chili";
          rev = "6516d50176c3b34df29003726ef9708813d06271";
          sha256 = "sha256-wxWsdRGC59YzDcSopDRzxg8TfjjmA3LHrdWjepTuzgw=";
        })}";
      };
      windowManager.i3 = {
        enable = true;
        extraPackages = with pkgs; [
          rofi
          i3status
          i3lock
          picom
          maim
          xdotool
          xclip
          alacritty
          networkmanagerapplet
          pasystray
          xss-lock
          feh
          libsForQt5.qt5.qtgraphicaleffects # For SDDM Theme
        ];
      };
    };
  };
}
