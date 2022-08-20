{ pkgs, lib, config, ... }:

{
  systemd.user.targets.tray = {
    Unit = {
      Description = "Home Manager System Tray";
      Requires = [ "graphical-session-pre.target" ];
    };
  };
  xsession.windowManager.i3 = {
    enable = true;
    config = {
      modifier = "Mod4";
      terminal = "alacritty";
      startup = [
        { command = "autorandr -l desktop"; }
        { command = "feh --bg-scale ~/Pictures/Wallpaper/murasame.png"; }
      ];
      keybindings = 
        let
          modifier = config.xsession.windowManager.i3.config.modifier;
        in lib.mkOptionDefault {
          # Move workspace to another screen
          "${modifier}+Control+Left" = "move workspace to output left";
          "${modifier}+Control+Right" = "move workspace to output right";
          "${modifier}+d" = "exec \"${pkgs.rofi}/bin/rofi -modi drun,run -show drun\"";
          # Screenshot
          "Print" = "exec flameshot launcher";
          "${modifier}+Shift+Print" = "exec flameshot gui";
          "Shift+Print" = "exec flameshot full";
          # Flameshot didn't provide a way to select a window
          "${modifier}+Print" = "exec --no-startup-id maim --window $(xdotool getactivewindow) | xclip -selection clipboard -t image/png";
        };
    };
  };
  services.picom = {
    enable = true;
    activeOpacity = 1.0;
    backend = "glx";
    experimentalBackends = true;
    settings = {
      frame-opacity = 0.8;
      inactive-opacity-override = false;
      blur-background = true;
      blur-baclground-exclude = [
        "window_type = 'dock'"
        "window_type = 'desktop'"
      ];
      blur = {
        method = "dual_kawase";
        strength = 10;
      };
    };
    opacityRules = [
      "90:class_g = 'Alacritty'"
    ];
  };
  services.flameshot = {
    enable = true;
    settings = {
      General = {
        disabledTrayIcon = true;
      };
    };
  };
  services.network-manager-applet.enable = true;
  services.pasystray.enable = true;
}
