{ pkgs, lib, ... }: {
  imports = [ ./hardware.nix ];

  nixpkgs.config.allowUnfreePredicate =
    pkg: builtins.elem (lib.getName pkg) [ 
      "p7zip" 
    ];

  networking = {
    hostName = "boobsos";
    hostId = "a6e15bda";
  };
}
