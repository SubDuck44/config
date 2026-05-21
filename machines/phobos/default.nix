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

  boot.kernelPatches = [{
    name = "Bluetooth: btmtk: accept too short WMT FUNC_CTRL events";
    patch = pkgs.fetchurl {
      url = "https://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next.git/patch/?id=162b1adeb057d28ad84fd8a03f3c50cf08db5c62";
      hash = "sha256-ij0hQmC0U++AdXWQy6nycnDe6z4yaMoQIrSiLal5DHc=";
    };
  }];

  home-manager.sharedModules = [{
    wayland.windowManager.hyprland.extraConfig = ''
      monitor = eDP-1, preferred, auto, 1.0
    '';
  }];
}
