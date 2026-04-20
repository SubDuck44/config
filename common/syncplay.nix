{ pkgs, lib, ... }: {
  home-manager.sharedModules = lib.singleton (hm: {
    home.packages = with pkgs; [
      syncplay
    ];

    xdg.configFile = {
      "syncplay.ini".text = lib.generators.toINI { } {
        server_data = {
          host = "exit.bunny.vpn";
          port = 8999;
        };

        client_settings = {
          name = "Melinda Amanita, First Floret";
          room = "Absolutes Kinori";

          playerpath = pkgs.writeShellScript "mpv-gpu" ''
            exec ${lib.getExe pkgs.mpv} --vo=gpu-next "$@"
          '';

          mediasearchdirectories = "['${hm.config.home.homeDirectory}/mov']";
        };

        general = {
          checkforupdatesautomatically = false;
        };
      };

      "Syncplay/MoreSettings.conf".text = lib.generators.toINI { } {
        MoreSettings = {
          ShowMoreSettings = true;
        };
      };
    };
  });
}
