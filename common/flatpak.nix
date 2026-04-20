{
  services.flatpak.enable = true;

  aquaris.persist.dirs = {
    "/var/lib/flatpak" = { };
  };

  home-manager.sharedModules = [{
    aquaris.persist = {
      ".local/share/flatpak" = { };
      ".var/app" = { };
    };
  }];
}
