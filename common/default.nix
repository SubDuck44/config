{ config, lib, pkgs, self, ... }: let
  inherit (lib) mkAfter getExe;
in
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

  imports = [
    self.inputs.home-manager.nixosModules.home-manager
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    kernelPackages = pkgs.linuxPackages_zen;
    zfs.package = pkgs.zfs_2_4;
  };

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

  users.mutableUsers = false;
  users.users.melinda = {
    shell = pkgs.zsh;
    isNormalUser = true;
    extraGroups = [ "wheel" "gamemode" "adbusers" "libvirtd" ];
    packages = with pkgs; [
      yt-dlp
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
      thunderbird
      android-tools
      aseprite
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
    virt-manager
  ];

  environment.etc."nixos".source = self;

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu.swtpm.enable = true;
    };

    spiceUSBRedirection.enable = true;
  };

  programs = {
    obs-studio = {
      enable = true;
      enableVirtualCamera = true;

      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-pipewire-audio-capture
        obs-vkcapture
      ];
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

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.melinda = { config, ... }: {
      xdg.configFile."flameshot/flameshot.ini".text = ''
        [General]
        useGrimAdapter=true
      '';

      gtk = {
        enable = true;
        theme = {
          name = "Gruvbox-Dark";
          package = pkgs.gruvbox-gtk-theme;
        };
      };

      services = {
        mako = {
          enable = true;
          settings = {
            default-timeout = 2000;
          };
        };

        emacs = {
          enable = true;
        };
        mpd = {
          enable = true;
          musicDirectory = "/home/melinda/sfx";
          extraConfig = ''
            audio_output {
              type "pulse"
              name "pulse"
            }
          '';
        };
      };

      programs = {
        librewolf = {
          enable = true;
          settings."privacy.resistFingerprinting" = false;
        };

        vesktop.enable = true;
        fuzzel.enable = true;
        git.enable = true;

        direnv = {
          enable = true;
          nix-direnv.enable = true;
        };

        htop = {
          enable = true;

          settings = {
            account_guest_in_cpu_meter = 1;
            color_scheme = 5;
            hide_userland_threads = 1;
            highlight_base_name = 1;
            highlight_changes = 1;
            highlight_changes_delay_secs = 1;
            show_cpu_frequency = 1;
            show_cpu_temperature = 1;
            show_merged_command = 1;
            show_program_path = 0;
            show_thread_names = 1;
            tree_view = 1;

            tree_sort_key = config.lib.htop.fields.COMM;
            tree_sort_direction = 1;

            fields = with config.lib.htop.fields; [
              PID
              USER
              STATE
              NICE
              PERCENT_CPU
              PERCENT_MEM
              M_RESIDENT
              OOM
              TIME
              COMM
            ];
          } // (with config.lib.htop; leftMeters [
            (bar "AllCPUs")
            (bar "Memory")
            (bar "Zram")
            (bar "DiskIO")
            (bar "NetworkIO")
            (bar "Load")
            (text "Clock")
          ]) // (with config.lib.htop; rightMeters [
            (text "AllCPUs")
            (text "Memory")
            (text "Zram")
            (text "DiskIO")
            (text "NetworkIO")
            (text "LoadAverage")
            (text "Uptime")
          ]);
        };

        zsh = {
          enable = true;
          oh-my-zsh = {
            enable = true;
            plugins = [
              "magic-enter"
            ];
            extraConfig = mkAfter (builtins.readFile ./zsh-cfg.sh);
          };
        };


        waybar = {
          enable = true;
          systemd = {
            enable = false;
          };
        };

        emacs = {
          enable = true;
          package = pkgs.emacs-pgtk;
        };

        jujutsu = {
          enable = true;
          settings = {
            ui = {
              always-allow-large-revsets = true;
              diff-formatter = [
                (getExe pkgs.difftastic)
                "--color=always"
                "$left"
                "$right"
              ];
            };
            user = {
              name = "melinda";
              email = "melinda.stobbe@mail.de";
            };
            signing = {
              backend = "ssh";
              behavior = "own";
              key = "/home/melinda/.ssh/id_ed25519";
            };
          };
        };

        ncmpcpp = {
          enable = true;
          settings = {
            lyrics_directory = "~/.local/share/lyrics";
            media_library_albums_split_by_date = "no";
            media_library_primary_tag = "album_artist";
            startup_screen = "browser";
          };
        };
      };

      home = {
        username = "melinda";
        homeDirectory = "/home/melinda";
        stateVersion = "25.11";

        pointerCursor = {
          name = "Vanilla-DMZ";
          size = 24;
          package = pkgs.vanilla-dmz;
          gtk.enable = true;
        };

        sessionVariables.LESS = "-i -R";

        shellAliases = {
          yoink = builtins.concatStringsSep " " [
            "yt-dlp"
            "--cookies-from-browser=firefox:~/.librewolf/9ucptchv.default-default"
            "--extract-audio --embed-metadata "
            "--output='%(playlist_index)02d - %(title)s.%(ext)s'"
          ];

          "work!" = "sudo nixos-rebuild switch --flake /home/melinda/cfg -L";

          j = "jj";
          ja = "jj abandon";
          jbd = "jj bookmark delete";
          jbl = "jj bookmark list --no-pager";
          jbla = "jj bookmark list --all --no-pager";
          jbs = "jj bookmark set";
          jbt = "jj bookmark track";
          jc = "jj git clone --colocate";
          jd = "jj describe -m";
          jde = "jj describe --edit";
          jdg = "jj diff --git";
          jdi = "jj diff";
          jdu = "jj duplicate";
          je = "jj edit";
          jfa = "jj file annotate";
          jfl = "jj file list";
          jfs = "jj file show";
          jfu = "jj file untrack";
          ji = "jj git init --colocate";
          jl = "jj log -r ::";
          jn = "jj new";
          jol = "jj op log";
          jor = "jj op restore";
          jos = "jj op show";
          jou = "jj op undo";
          jpa = "jj parallelize";
          jpl = "jj git fetch --all-remotes"; # "pull"
          jpu = "jj git push --all --deleted"; # jps is intelligent push
          jr = "jj rebase";
          jra = "jj git remote add";
          jrd = "jj git remote remove"; # "delete"
          jre = "jj restore";
          jrei = "jj restore -i";
          jrl = "jj git remote list --no-pager";
          jrr = "jj git remote rename";
          jrs = "jj git remote set-url";
          js = "jj show";
          jsc = "jj show $(jfc)";
          jsg = "jj show --git";
          jsp = "jj split";
          jsq = "jj squash";
          jsqi = "jj squash -i";
          jss = "jj show --stat";
          jtd = "jj tag delete";
          jtl = "jj tag list --no-pager";
          jts = "jj tag set --allow-move";
          ju = "jj undo";
        };
      };

      wayland.windowManager.hyprland = {
        enable = true;
        extraConfig = builtins.readFile ./hyprland.conf;
      };
    };
  };
}
