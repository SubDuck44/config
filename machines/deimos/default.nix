{ aquaris, pkgs, lib, ... }: {
  imports = [ ../../common ];

  aquaris = {
    machine = {
      id = "9f7777901bbb61ae632ed7bd69e65625";
    };

    users = lib.mkMerge [
      { inherit (aquaris.cfg.users) melinda; }
      { melinda.admin = true; }
    ];

    unfreeNames = [
      "nvidia-x11"
      "nvidia-settings"
      "steam"
      "steam-unwrapped"
      "factorio-space-age"
    ];

    dnscrypt.protos.dnscrypt = false;
  };

  system.extraDependencies = with pkgs; [
    factorio-space-age.src
  ];

  hardware.nvidia = {
    open = false;
    powerManagement.enable = true;
  };

  services = {
    xserver.videoDrivers = [ "nvidia" ];

    wivrn = {
      enable = true;
      openFirewall = true;
      steam.importOXRRuntimes = true;
    };
  };

  programs = {
    steam.enable = true;
  };

  home-manager.sharedModules = [{
    aquaris.persist = {
      ".factorio" = { };

      ".config/unity3d" = { };
      ".config/wivrn" = { };

      ".local/share/PrismLauncher" = { };
      ".local/share/Steam" = { };
      ".local/share/shapez.io" = { };
    };

    home.packages = with pkgs; [
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
  }];
}
