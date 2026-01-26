{ pkgs, lib, ... }: {
  imports = [ ./hardware.nix ];

  nixpkgs.config.allowUnfreePredicate =
    pkg: builtins.elem (lib.getName pkg) [
      "p7zip"
      "aseprite"
    ];

  networking = {
    hostName = "boobsos";
    hostId = "a6e15bda";
    wireless = {
      allowAuxiliaryImperativeNetworks = true;
    };
  };

  home-manager.sharedModules = [{
    wayland.windowManager.hyprland.extraConfig = ''
      monitor = eDP-1, preferred, auto, 1.2
    '';
  }];
}
