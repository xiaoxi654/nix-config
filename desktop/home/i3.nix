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
        { command = "fcitx5"; notification = false; }
        { command = "picom -b"; notification = false; }
        { command = "autorandr -l desktop"; }
        { command = "feh --bg-scale ~/Pictures/Wallpaper/murasame.png"; }
        { command = "nm-applet"; notification = false; }
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
          "Shift+Print" = "exec --no-startup-id maim | xclip -selection clipboard -t image/png";
          "${modifier}+Print" = "exec --no-startup-id maim --window $(xdotool getactivewindow) | xclip -selection clipboard -t image/png";
          "${modifier}+Shift+Print" = "exec --no-startup-id maim --select | xclip -selection clipboard -t image/png";
        };
    };
  };
  services.pasystray.enable = true;
}
