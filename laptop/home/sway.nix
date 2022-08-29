{ pkgs, ... }:

{
  home.packages = with pkgs; [
    swaylock
    swayidle
    rofi
    picom
    xdotool
    xclip
    alacritty
    networkmanagerapplet
    pasystray
    feh
  ];

  wayland.windowManager.sway = {
    enable = true;
    extraOptions = [
      "--unspported-gpu"
    ];
    wrapperFeatues.gtk = true;
    config = {
      modifier = "Mod4";
      terminal = "alacritty";
      input = {

      };
      # output = {
      # 
      # };
      startup = [
        { command = "fcitx5"; notification = false; }
      ];
      keybindings = 
      let
        modifier = config.wayland.windowManager.sway.modifier;
      in lib.mkOptionDefault {
        "${modifier}+d" = "exec \"${pkgs.rofi}/bin/rofi -modi drun,run -show drun\"";
        "Print" = "exec flameshot launcher";
        "${modifier}+Shift+Print" = "exec flameshot gui";
        "Shift+Print" = "exec flameshot full";
        "${modifier}+Print" = "exec --no-startup-id maim --window $(xdotool getactivewindow) | xclip -selection clipboard -t image/png";
      };
    };
  };

  services.flameshot = {
    enable = true;
    settings = {
      General = {
        disabledTrayIcon = true;
      };
    };
  };
  
  programs.swaylock.settings = {
    show-failed-attempts = true;
    daemonize = true;
  }
}
