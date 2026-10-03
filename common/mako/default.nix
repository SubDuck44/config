{
  home-manager.sharedModules = [{
    services.mako = {
      enable = true;

      settings = {
        font = "Iosevka NF";
        default-timeout = 7000;
        background-color = "#282828c0";
        text-color = "#d5c4a1";
        border-radius = 5;
        border-color = "#458588";
        icon-location = "left";
        icon-border-radius = 999;
        output = "DP-6";
        layer = "overlay";
        anchor = "top-right";
        on-notify = "exec mpv ${./notif.opus}";

        "app-name=Emacs" = {
          on-notify = "exec mpv ${./error.opus}";
          text-color = "#dbc823";
          border-color = "#dbc823";
        };

        "app-name=flameshot" = {
          invisible = true;
        };
      };
    };
  }];
}
