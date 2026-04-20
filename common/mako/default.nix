{
  home-manager.sharedModules = [{
    services.mako = {
      enable = true;

      settings = {
        font = "Iosevka NF";
        default-timeout = 7000;
        background-color = "#282828f0";
        text-color = "#5bcefa";
        border-radius = 7;
        border-color = "#5bcefaff";
        icon-location = "left";
        icon-border-radius = 999;
        output = "DP-6";
        layer = "overlay";
        anchor = "bottom-left";
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
