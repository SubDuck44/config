{ pkgs, ... }: {
  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;

    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-pipewire-audio-capture
      obs-vkcapture
    ];
  };

  home-manager.sharedModules = [{
    aquaris.persist = {
      ".config/obs-studio" = { };
    };

    xdg.desktopEntries = {
      "com.obsproject.Studio" = {
        name = "OBS Studio";
        icon = "com.obsproject.Studio";
        exec = "env LD_LIBRARY_PATH=/run/opengl-driver/lib obs";
      };
    };
  }];
}
