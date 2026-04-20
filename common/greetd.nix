{ pkgs, lib, ... }: {
  aquaris.persist.dirs = { "/var/cache/tuigreet" = { }; };

  services.greetd = {
    enable = true;
    restart = true;

    settings = {
      default_session.command = "${lib.getExe pkgs.tuigreet} -tr --remember-user-session";
      terminal.vt = lib.mkForce 7;
    };
  };
}
