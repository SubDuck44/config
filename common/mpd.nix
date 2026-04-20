{ lib, ... }: {
  home-manager.sharedModules = lib.singleton (hm: {
    aquaris.persist = {
      ".local/share/mpd" = { };
    };

    services = {
      mpd = {
        enable = true;
        musicDirectory = "${hm.config.home.homeDirectory}/sfx";
        extraConfig = ''
          audio_output {
            type "pulse"
            name "pulse"
          }
        '';
      };

      mpd-mpris.enable = true;
    };

    programs.ncmpcpp = {
      enable = true;
      settings = {
        lyrics_directory = "~/.local/share/lyrics";
        media_library_albums_split_by_date = "no";
        media_library_primary_tag = "album_artist";
        startup_screen = "browser";
      };
    };
  });
}
