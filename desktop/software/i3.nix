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
      displayManager.sddm.enable = true;
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
          xss-lock
          feh
        ];
      };
    };
  };
}
