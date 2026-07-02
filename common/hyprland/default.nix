{ pkgs, ... }: {
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
    config = {
      hyprland = {
        default = [ "hyprland" "gtk" ];
        "org.freedesktop.impl.portal.OpenURI" = [ "gtk" ];
      };
    };
  };

  home-manager.sharedModules = [{
    wayland.windowManager.hyprland = {
      enable = true;
      configType = "lua";
      extraConfig = builtins.readFile ./hyprland.lua;
    };
  }];
}
