{
  home-manager.sharedModules = [{
    programs.yt-dlp = {
      enable = true;
      settings = {
        cookies-from-browser = "firefox:~/.librewolf/default";
        format-sort = "vcodec:h264,quality";
      };
    };

    home.shellAliases = {
      yoink = builtins.concatStringsSep " " [
        "yt-dlp"
        "--extract-audio --embed-metadata "
        "--output='%(playlist_index)02d - %(title)s.%(ext)s'"
      ];
    };
  }];
}
