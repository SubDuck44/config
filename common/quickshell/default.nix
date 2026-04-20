{ lib, ... }: {
  home-manager.sharedModules = [{
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
