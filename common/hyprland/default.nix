{ pkgs, ... }: {
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  home-manager.sharedModules = [{
    xdg = {
      portal = {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-hyprland
          xdg-desktop-portal-gtk
        ];
      };

      systemDirs.data = with pkgs; map glib.getSchemaDataDirPath [
        gsettings-desktop-schemas
        gtk3
      ];

      configFile."xkb/symbols/spanish".text = ''
        xkb_symbols "basic" {
          include "de(nodeadkeys)"
          replace key <AC01> {[a, A, aacute, Aacute]};
          replace key <AD03> {[e, E, eacute, Eacute]};
          replace key <AD08> {[i, I, iacute, Iacute]};
          replace key <AD09> {[o, O, oacute, Oacute]};
          replace key <AD07> {[u, U, uacute, Uacute]};
          replace key <AB06> {[n, N, ntilde, Ntilde]};
        };
      '';
    };

    wayland.windowManager.hyprland = {
      enable = true;
      configType = "lua";
      extraConfig = builtins.readFile ./hyprland.lua;
    };
  }];
}
