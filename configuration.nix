{ config, lib, pkgs, self, ... }:

{

  nix = {
    settings = {
      substituters = [
        "https://attic.eleonora.gay/default"
      ];
      trusted-public-keys = [
        "default:3FYh8sZV8gWa7Jc5jlP7gZFK7pt3kaHRiV70ySaQ42g="
      ];
    };
  };

  nixpkgs.overlays = [
    (_: prev:
      let obscura = self.inputs.obscura.packages.${prev.stdenv.hostPlatform.system}; in {
        inherit (obscura.nvidia.entries)
          nvtop;
        factorio-space-age = prev.factorio-space-age.override {
          makeDesktopItem = { exec, ... }@args: prev.makeDesktopItem (args // {
            exec = "gamemoderun ${exec}";
          });
        };
      }
    )
  ];

  imports = [ ./hardware-configuration.nix ];

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelPackages = pkgs.linuxPackages_zen;
    zfs.package = pkgs.zfs_2_4;
  };

  networking.hostName = "tittyos";
  networking.hostId = "c204338e";

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = lib.mkForce "de-latin1";
    useXkbConfig = true;
  };

  services = {
    zfs = {
      autoSnapshot.enable = true;
      autoScrub.enable = true;
      trim.enable = true;
    };
    pipewire = {
      enable = true;
      pulse.enable = true;
    };
    keyd = {
      enable = true;
      keyboards.default = {
        ids = [ "*" ];
        settings.main = {
          capslock = "layer(control)";
        };
      };
    };
    wivrn = {
      enable = true;
      openFirewall = true;
      defaultRuntime = true;
      steam.importOXRRuntimes = true;
    };
    tailscale = {
      enable = true;
      openFirewall = true;
      useRoutingFeatures = "client";
    };
  };

  systemd.network.wait-online.ignoredInterfaces = [
    "tailscale0"
  ];
  security.sudo.extraConfig = "Defaults insults";

  nixpkgs.config.allowUnfreePredicate =
    pkg: builtins.elem (lib.getName pkg) [
      "nvidia-x11" "nvidia-settings"
      "steam" "steam-unwrapped"
      "p7zip"
      "factorio-space-age"
    ];

  system.extraDependencies = with pkgs; [
    factorio-space-age.src
  ];
  
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = false;

  users.mutableUsers = false;
  users.users.melinda = {
    shell = pkgs.zsh;
    isNormalUser = true;
    extraGroups = [ "wheel" "gamemode" "adbusers" ];
    packages = with pkgs; [
      factorio-space-age
      cmatrix
      hyfetch
      fastfetch
      wl-clipboard
      pulsemixer
      playerctl
      grim
      flameshot
      swaybg
      mpv
      qbittorrent
      feh
      ffmpeg
      (prismlauncher.override {
        jdks = with pkgs.javaPackages.compiler.temurin-bin; [
          jre-25
          jre-17
          jre-8
        ];
      })
      thunderbird
      android-tools
    ];
    hashedPasswordFile = "/secrets/melinda.pwhash";
  };

  environment.systemPackages = with pkgs; [
    lsof
    wget
    tree
    nvtop
    htop
    man-pages
    man-pages-posix
    libqalculate
    libnotify
    p7zip-rar
    nixpkgs-fmt
  ];

  environment.etc."nixos".source = self;

  programs = {
    obs-studio = {
      enable = true;

      package = (
        pkgs.obs-studio.override {
          cudaSupport = true;
        }
      );

      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-pipewire-audio-capture
        obs-vkcapture
      ];
      enableVirtualCamera = true;
    };
    hyprland = {
      enable = true;
    };

    foot = {
      enable = true;
      settings = {
        colors.alpha = 0.2;
      };
    };

    steam = {
      enable = true;
    };
    zsh = {
      enable = true;
      enableGlobalCompInit = false;
    };
    gamemode.enable = true;
  };

  services.openssh.enable = true;

  networking.firewall.enable = false; # TODO

  system.stateVersion = "25.11";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  fonts = {
    packages = with pkgs; [
      nerd-fonts.iosevka
      noto-fonts
      noto-fonts-color-emoji
    ];

    fontconfig.defaultFonts = {
      emoji = [ "Noto Color Emoji" ];
      monospace = [ "IosevkaNerdFont" ];
      sansSerif = [ "Noto Sans" ];
      serif = [ "Noto Serif" ];
    };
  };
}
