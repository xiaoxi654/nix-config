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
        { command = "feh --bg-scale ~/Pictures/Wallpaper/murasame.png"; notification = false; }
        { command = "fcitx5"; notification = false; }
      ];
      keybindings = 
        let
          modifier = config.xsession.windowManager.i3.config.modifier;
        in lib.mkOptionDefault {
          # App launcher
          "${modifier}+d" = "exec \"${pkgs.rofi}/bin/rofi -modi drun,run -show drun\"";
          # Volume Control
          "XF86AudioMicMute" = "exec --no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle";
          "XF86AudioMute" = "exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle";
          "XF86AudioRaiseVolume" = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +2%";
          "XF86AudioLowerVolume" = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -2%";
          # Backlight Control
          "XF86MonBrightnessUp" = "exec --no-startup-id brightnessctl s 5%+";
          "XF86MonBrightnessDown" = "exec --no-startup-id brightnessctl s 5%-";
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

  services = {
    flameshot = {
      enable = true;
      settings = {
        General = {
          disabledTrayIcon = true;
        };
      };
    };
    network-manager-applet.enable = true;
    pasystray.enable = true;
  };

  programs.i3status = {
    enable = true;
    enableDefault = false;
    general = {
      colors = true;
      color_good = "#88b090";
      color_degraded = "#ccdc90";
      color_bad = "#e89393";
      interval = 1;
    };
    modules = {
      "wireless wlp4s0" = {
        position = 1;
        settings = {
          format_up = "W: %ip (%quality at %essid)";
          format_down = "W: Disconnected";
        };
      };
      "ethernet _first_" = {
        position = 2;
        settings = {
          format_up = "E: %ip (%speed)";
          format_down = "";
        };
      };
      "battery all" = {
        position = 3;
        settings = {
          format = "%status %percentage %remaining";
          last_full_capacity = true;
          low_threshold = 20;
          threshold_type = "percentage";
          hide_seconds = true;
          status_chr = "CHR";
          status_bat = "BAT";
          status_full = "FUL";
          status_unk = "UNK";
        };
      };
      "load" = {
        position = 4;
        settings = {
          format = "%1min";
        };
      };
      "memory" = {
        position = 5;
        settings = {
          format = "Avail: %available|%used/%total";
          threshold_degraded = "1G";
          format_degraded = "MEMORY < %available|%used/%total";
        };
      };
      "volume master" = {
        position = 6;
        settings = {
          format = "Audio: %volume";
          format_muted = "Audio: Muted";
          device = "default";
          mixer = "Master";
          mixer_idx = 0;
        };
      };
      "tztime local" = {
        position = 7;
        settings = {
          format = "%Y-%m-%d %H:%M:%S";
        };
      };
    };
  };
}
