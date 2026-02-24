{ pkgs, lib, ... }: {
  imports = [ ./hardware.nix ];

  tits.unfreeNames = [
    "nvidia-x11"
    "nvidia-settings"
    "steam"
    "steam-unwrapped"
    "factorio-space-age"
  ];

  system.extraDependencies = with pkgs; [
    factorio-space-age.src
  ];

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = false;

  networking = {
    hostName = "tittyos";
    hostId = "c204338e";
  };

  services = {
    wivrn = {
      enable = true;
      openFirewall = true;
      defaultRuntime = true;
      steam.importOXRRuntimes = true;
    };
  };

  users.users.melinda = {
    packages = with pkgs; [
      factorio-space-age

      (prismlauncher.override {
        jdks = with pkgs.javaPackages.compiler.temurin-bin; [
          jre-25
          jre-21
          jre-17
          jre-8
        ];
      })
    ];
  };

  programs = {
    steam = {
      enable = true;
    };
  };
}
