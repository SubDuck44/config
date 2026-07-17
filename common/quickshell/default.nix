{ pkgs, lib, ... }: {
  home-manager.sharedModules = [{
    home.packages = with pkgs; [
      (pkgs.runCommandCC "bar-info" { } ''
        mkdir -p $out/bin
        cc -Wall -Wextra -O3 ${./bar-info.c} -o $out/bin/bar-info
      '')
    ];

    programs.quickshell = {
      enable = true;
      activeConfig = "default";

      systemd = {
        enable = true;
        target = "hyprland-session.target";
      };
    };

    systemd.user = {
      services = {
        quickshell = {
          Service = {
            Restart = lib.mkForce "always";
          };

          Unit = {
            StartLimitIntervalSec = 0;
          };
        };
      };

      tmpfiles.rules = [
        "L+ %h/.config/quickshell/default - - - - %h/cfg/common/quickshell"
      ];
    };
  }];
}
