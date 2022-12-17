{ pkgs, lib, config, ... }:

{
  programs = {
    waybar = {
      enable = true;
      style = builtins.readFile ./files/waybar.css;
      systemd.enable = true;
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 25;
          modules-left = [ "wlr/workspaces" ];
          #
          # "sway/mode"
          modules-center = [ "clock" ];
          modules-right = [ "network" "temperature" "cpu" "memory" "pulseaudio" "tray" ];
          "sway/mode" = {
            format = " {}";
          };
          "sway/workspaces" = {
            format = "{name}";
            disable-scroll = true;
          };
          "wlr/workspaces" = {
            format = "{icon}";
            on-click = "activate";
          };
          "sway/window" = {
            max-length = 80;
            tooltip = false;
          };
          "tray" = {
            "icon-size" = 15;
            "spacing" = 5;
          };
          disk = {
            interval = 30;
            format = "{percentage_free}% free on {path}";
          };
          clock = {
            format = "{:%H:%M}";
            timezone = "Asia/Shanghai";
            format-alt = "{:%a %d %b}";
            format-alt-click = "click-right";
            tooltip = false;
          };
          cpu = {
            interval = 1;
            format = "{usage}% ";
            max-length = 10;
            min-length = 5;
          };
          memory = {
            interval = 1;
            format = "{}% ";
            max-length = 10;
            min-length = 5;
            tooltip = false;
          };
          network = {
            interval = 1;
            interface = "enp0s31f6";
            on-click = "alacritty -e nmtui";
            format = "{ifname}: {ipaddr}/{cidr}";
            tooltip = false;
          };
          pulseaudio = {
            min-length = 5;
            format = "{volume}% {icon}";
            format-alt = "{volume} {icon}";
            format-alt-click = "click-right";
            format-muted = "x";
            format-icons = {
              phone = [ " " " " " 墳" " " ];
              default = [ "" "墳" "" ];
            };
            on-click = "pavucontrol";
            scroll-step = 1;
            tooltip = false;
          };
          temperature = {
            interval = 2;
            hwmon-path = "/sys/class/hwmon/hwmon2/temp1_input";
            format = "{temperatureC}°C ";
            max-length = 10;
            min-length = 5;
            tooltip = false;
          };
          idle_inhibitor = {
            format = "{icon}";
            format-icons = {
              activated = "";
              deactivated = "";
            };
            tooltip = false;
          };
        };
      };
    };
  };
}