{ ... }: {
  home-manager.sharedModules = [{
    programs.waybar = {
      enable = true;
      style = ./style.css;
      systemd = {
        enable = true;
      };
    };
  }];
}
