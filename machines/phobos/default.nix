{ aquaris, pkgs, lib, ... }: {
  imports = [ ../../common ];

  aquaris = {
    machine = {
      id = "6eb999cc2313ba866c79393469e65937";
    };

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
      monitor = eDP-1, preferred, auto, 1.0
    '';
  }];
}
