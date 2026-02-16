{ pkgs, lib, ... }: {
  imports = [ ./hardware.nix ];

  networking = {
    hostName = "boobsos";
    hostId = "a6e15bda";
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
      monitor = eDP-1, preferred, auto, 1.2
    '';
  }];
}
