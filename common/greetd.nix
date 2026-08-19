{ pkgs, lib, config, ... }: {
  aquaris.persist.dirs = { "/var/cache/tuigreet" = { }; };

  services.greetd = {
    enable = true;
    restart = true;
    useTextGreeter = true;

    settings = {
      default_session.command =
        let
          sessions = config.services.displayManager.sessionData.desktops
            + "/share/wayland-sessions";
        in
        lib.join " " [
          (lib.getExe pkgs.tuigreet)
          "--asterisks"
          "--background matrix"
          "--time"
          "--remember"
          "--remember-user-session"
          "--sessions ${sessions}"
        ];

      terminal.vt = lib.mkForce 7;
    };
  };
}
