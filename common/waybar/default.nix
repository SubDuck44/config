{ ... }: {
  home-manager.sharedModules = [{
    programs.waybar = {
      enable = true;
      style = ./style.css;
      settings.default = {
        layer = "top";
        position = "top";
        height = 24;
        spacing = 4;

        modules-left = [
          "clock"
          "cpu"
          "temperature"
          "memory"
          "hyprland/workspaces"
          "battery"
        ];
        modules-right = [
          "mpd"
          "pulseaudio"
          "network"
          "tray"
        ];
        modules-center = [
          "hyprland/window"
        ];

        mpd = {
          format = ''
            {stateIcon}{consumeIcon}{randomIcon}{repeatIcon}{singleIcon}
            {artist} - {title} ({elapsedTime:%M:%S}/{totalTime:%M:%S})
            ⸨{songPosition}|{queueLength}⸩
          '';
          format-disconnected = "disconnected from mpd";
          format-stopped = "";
          unknown-tag = "N/A";
          interval = 5;
          max-length = 80;

          consume-icons = {
            on = "「R」";
          };
          random-icons = {
            on = "「z」";
          };
          repeat-icons = {
            on = "「r」";
          };
          single-icons = {
            on = "「y」";
          };
          state-icons = {
            paused = "Now playing: ";
            playing = "Ready: ";
          };
          tooltip-format = "";
          tooltip-format-disconnected = "";
        };

        tray = {
          icon-size = 15;
          spacing = 10;
        };

        clock = {
          timezone = "Germany/Berlin";
          interval = 1;
          format = "{:%T %F}";
        };

        cpu = {
          format = "  {usage}%";
          interval = 1;
          tooltip = false;
        };

        memory = {
          format = "  {percentage}%";
        };

        temperature = {
          hwmon-path = "/dev/cpu_temp";
          critical-threshold = 80;

          format = "{temperatureC}°C {icon}";
          format-icons = [ "󰉬" "" "󰉪" ];
        };

        battery = {
          states = {
            good = 95;
            warning = 30;
            critical = 15;
          };

          format = "{icon} {capacity}% {time}";
          format-full = "{icon} {capacity}%";
          format-charging = "{icon} {capacity}% {time} 󰃨";
          format-plugged = "{capacity}% ";
          format-icons = [ "" "" "" "" "" ];

          smooth-power = true;
        };

        "hyprland/window" = {
          format = "{title}";
          fallback = "nothing here...";
          tooltip-format = "init: {initialTitle}\nclass: {class}\ninit-class: {initialClass}";
          separate-outputs = false;

          icon = true;
          icon-size = 15;

          expand = true;
        };

        "hyprland/workspaces" = {
          format = "{icon}";
          format-icons = {
            "101" = "1";
            "102" = "2";
            "103" = "3";
            "104" = "4";
            "105" = "5";
            "106" = "6";
            "107" = "7";
            "108" = "8";
            "109" = "9";
          };
        };

        network = {
          format-wifi = "{essid} ({signalStrength}%)";
          format-ethernet = "{ipaddr}/{cidr}";
          format-linked = "{ifname} (No IP)";
          format-disconnected = "disconnected";
          format-alt = "{ifname}: {ipaddr}/{cidr}";

          tooltip-format = "{ifname} via {gwaddr}";
        };

        pulseaudio = {
          format = "{volume}% {icon} {format_source}";
          format-bluetooth = "{volume}% {icon} {format_source}";
          format-bluetooth-muted = "󰅶 {icon} {format_source}";
          format-muted = "󰅶 {format_source}";
          format-source = "{volume}% ";
          format-source-muted = "";
          format-icons = {
            "headphone" = "";
            "hands-free" = "󰂑";
            "headset" = "󰂑";
            "phone" = "";
            "portable" = "";
            "car" = "";
            "default" = [ "" "" "" ];
          };
        };
      };
      systemd = {
        enable = true;
      };
    };
  }];
}
