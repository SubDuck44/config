{ pkgs, lib, ... }: {
  home-manager.sharedModules = [{
    systemd.user.services.swaybg = {
      Install.WantedBy = [ "graphical-session.target" ];
      Service.ExecStart = ''
        ${lib.getExe pkgs.swaybg} -i ${./wallpaper.png}
      '';
    };
  }];
}
