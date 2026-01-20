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
    ./dnscrypt.nix
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    kernelPackages = pkgs.linuxPackages_zen;
    zfs.package = pkgs.zfs_2_4;
  };

  networking = {
    networkmanager.enable = true;
    useNetworkd = true;
  };

  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";

  console = {
    font = "Lat2-Terminus16";
    keyMap = lib.mkForce "de-latin1";
    useXkbConfig = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
    config = {
      hyprland = {
        default = [ "hyprland" "gtk" ];
        "org.freedesktop.impl.portal.OpenURI" = [ "gtk" ];
      };
    };
  };
  
  services = {
    greetd = {
      enable = true;
      restart = true;

      settings = {
        default_session.command = "${getExe pkgs.tuigreet} -tr --remember-user-session";

        terminal.vt = lib.mkForce 7;
      };
    };
    
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

  systemd.network.wait-online.enable = false;

  security.sudo.extraConfig = "Defaults insults";

  users.mutableUsers = false;
  users.users.melinda = {
    shell = pkgs.zsh;
    isNormalUser = true;
    extraGroups = [ "wheel" "gamemode" "adbusers" "libvirtd" ];
    packages   = with pkgs; [
      self.inputs.keysmash.packages.${stdenv.system}.default
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
    SDL2
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
      withUWSM = true;
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

      imports = [
        "${self.inputs.aquaris}/module/home/emacs"
        ./emacs.nix
      ];

      gtk = {
        enable = true;
        theme = {
          name = "Gruvbox-Dark";
          package = pkgs.gruvbox-gtk-theme;
        };
      };

      services = {
        syncthing.enable = true;
        
        mako = {
          enable = true;
          settings = {
            default-timeout = 5000;
            background-color = "#ffffff40";
            text-color = "#debffc";
            border-radius = 7;
            border-color = "#bb77ff40";
            icon-location = "right";
            icon-border-radius = 999;
            output = "DP-6";
            layer = "overlay";
            anchor = "top-center";
            "app-name=Emacs" = {
              on-notify = "exec mpv ${./error.opus}";
              text-color = "#dbc823";
              border-color = "#dbc823";
            };
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

          "sneeptime" = "systemctl suspend";
          "work!" = "sudo nixos-rebuild switch --flake /home/melinda/cfg -L";
          "die!" = "poweroff";
          "crush!" = "nix store gc -v";
          "judgement!" = "systemctl --user restart emacs";
          "thy-end-is-now!" = "sudo nix-env --delete-generations +3 --profile /nix/var/nix/profiles/system";
          "prepare-thyself!" = "reboot";

          "branch-delete" = "jj bookmark delete";
          "branch-fetch" = "jj git fetch --all-remotes"; # "pull"
          "branch-move" = "jj bookmark set";
          "branch-push" = "jj git push --all --deleted"; # jps is intelligent push
          "branch-rebase" = "jj rebase";
          "branch-show" = "jj bookmark list --no-pager";
          "branch-showoff" = "jj bookmark list --all --no-pager";
          "branch-sync" = "jj bookmark track";
          "commit-blame" = "jj file annotate";
          "commit-delete" = "jj abandon";
          "commit-deletemark" = "jj tag delete";
          "commit-describe" = "jj describe -m";
          "commit-describe-again" = "jj describe --edit";
          "commit-diff" = "jj diff";
          "commit-diff-git" = "jj diff --git";
          "commit-duplicate" = "jj duplicate";
          "commit-edit" = "jj edit";
          "commit-listmarks" = "jj tag list --no-pager";
          "commit-makeinverted" = "jj restore";
          "commit-makeinverted-better" = "jj restore -i";
          "commit-mark" = "jj tag set --allow-move";
          "commit-new" = "jj new";
          "commit-show" = "jj show";
          "commit-show-git" = "jj show --git";
          "commit-showlastready" = "jj show $(jfc)";
          "commit-split" = "jj split";
          "commit-squish" = "jj squash";
          "commit-squish-better" = "jj squash -i";
          "commit-stat" = "jj show --stat";
          "file-forget" = "jj file untrack";
          "file-list" = "jj file list";
          "file-show" = "jj file show";
          "repo-clone" = "jj git clone --colocate";
          "repo-connect" = "jj git remote add";
          "repo-disconnect" = "jj git remote remove"; # "delete"
          "repo-expose" = "jj op log";
          "repo-incest" = "jj parallelize";
          "repo-infodump" = "jj log -r ::";
          "repo-listremotes" = "jj git remote list --no-pager";
          "repo-new" = "jj git init --colocate";
          "repo-renameremote" = "jj git remote rename";
          "repo-restoreto" = "jj op restore";
          "repo-setremoteurl" = "jj git remote set-url";
          "repo-showop" = "jj op show";
          "repo-undo" = "jj op revert";
        };
      };

      wayland.windowManager.hyprland = {
        enable = true;
        extraConfig = builtins.readFile ./hyprland.conf;
      };
    };
  };
}
