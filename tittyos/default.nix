{ pkgs, lib, ... }: {
  imports = [ ./hardware.nix ];

  nixpkgs.config.allowUnfreePredicate = 
    pkg: builtins.elem (lib.getName pkg) [ 
      "nvidia-x11" "nvidia-settings"
      "steam" "steam-unwrapped"
      "p7zip" 
      "factorio-space-age"
      "aseprite"
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
          jre-17
          jre-8
        ];
      })
    ];
  };

  programs = {
    obs-studio = {
      package = pkgs.obs-studio.override {
        cudaSupport = true;
      };
    };

    steam = {
      enable = true;
    };
  };
}
