{ aquaris, pkgs, lib, ... }: {
  imports = [ ../../common ];

  aquaris = {
    machine.id = "9f7777901bbb61ae632ed7bd69e65625";
    secrets.pub = "CqxpOPQggAlO2Et1kV064dZaLz2L8H7JeI0c1Xh3m0M";

    users = lib.mkMerge [
      { inherit (aquaris.cfg.users) melinda; }
      { melinda.admin = true; }
    ];

    unfreeNames = [
      "nvidia-kernel-modules"
      "nvidia-x11"

      "steam"
      "steam-unwrapped"

      "factorio-space-age"
    ];
  };

  system.extraDependencies = with pkgs; [
    factorio-space-age.src
  ];

  hardware.nvidia = {
    open = false;
    nvidiaSettings = false;
    powerManagement.enable = true;
  };

  hardware.graphics.extraPackages = [ pkgs.monado-vulkan-layers ];

  services = {
    xserver.videoDrivers = [ "nvidia" ];

    wivrn = {
      enable = true;
      openFirewall = true;
      steam.importOXRRuntimes = true;
    };

    udev.extraRules = ''
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="10f5", \
      MODE="0660", GROUP="users", TAG+="uaccess"
    '';
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
      ((pkgs.runCommandCC "unfuck-yoke" {
        nativeBuildInputs = with pkgs; [ pkg-config ];
        buildInputs = with pkgs; [ libusb1 ];
      }) ''
        mkdir -p $out/bin
        cc $(pkg-config --cflags --libs libusb-1.0) ${./unfuck-yoke.c} -o $out/bin/unfuck-yoke
      '')

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

    wayland.windowManager.hyprland.extraConfig = ''
      monitor = DP-6, preferred, auto, 1
      monitor = DP-5, preferred, auto-left, 1
    '';
  }];
}
