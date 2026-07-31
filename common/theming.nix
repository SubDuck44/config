{ pkgs, ... }: {
  home-manager.sharedModules = [{
    xdg.systemDirs.data = with pkgs; map glib.getSchemaDataDirPath [
      gsettings-desktop-schemas
      gtk3
    ];

    gtk = rec {
      enable = true;

      theme = {
        name = "gruvbox-dark";
        package = pkgs.gruvbox-dark-gtk;
      };

      iconTheme = {
        name = "Adwaita";
        package = pkgs.adwaita-icon-theme;
      };

      gtk4 = { inherit theme; };
    };

    qt = {
      enable = true;
      platformTheme.name = "gtk3";
    };

    home = {
      pointerCursor = {
        enable = true;
        gtk.enable = true;

        name = "catppuccin-macchiato-dark-cursors";
        size = 24;
        package = pkgs.catppuccin-cursors.macchiatoLight;
      };

      packages = with pkgs; [
        qt5.qtwayland
        qt6.qtwayland
      ];
    };
  }];
}
