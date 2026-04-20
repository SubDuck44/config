{ pkgs, ... }: {
  aquaris.persist.dirs = {
    "/var/lib/private/gomuks-web" = { };
  };

  systemd.services.gomuks-web = {
    path = with pkgs; [ gomuks-web ];
    script = ''
      export GOMUKS_ROOT="$STATE_DIRECTORY"
      exec gomuks-web << EOF
      admin
      admin
      EOF
    '';

    serviceConfig = {
      Type = "simple";
      DynamicUser = true;
      StateDirectory = "gomuks-web";
    };

    wantedBy = [ "default.target" ];
  };
}
