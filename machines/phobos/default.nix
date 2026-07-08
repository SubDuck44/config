{ aquaris, pkgs, lib, ... }: {
  imports = [ ../../common ];

  aquaris = {
    machine.id = "6eb999cc2313ba866c79393469e65937";
    secrets.pub = "xn7WBCrQTp--Kav5RxaMslcdfpgUXH1vBp3J1cXelQI";

    users = lib.mkMerge [
      { inherit (aquaris.cfg.users) melinda; }
      { melinda.admin = true; }
    ];
  };

  networking = {
    wireless = {
      allowAuxiliaryImperativeNetworks = true;
    };
  };

  environment = {
    systemPackages = with pkgs; [
      brightnessctl
    ];
  };

  home-manager.sharedModules = [{
    wayland.windowManager.hyprland.extraConfig = ''
      hl.monitor({
        output = "eDP-1",
        mode = "preferred",
        position = "auto",
        scale = 1.0,
      })
    '';
  }];
}
