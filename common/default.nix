{ config, lib, pkgs, self, ... }:
let inherit (lib) mkMerge getExe; in
{
  nix = {
    settings = {
      substituters = [
        "https://attic.eleonora.gay/default"
      ];

      trusted-public-keys = [
        "default:3FYh8sZV8gWa7Jc5jlP7gZFK7pt3kaHRiV70ySaQ42g="
      ];

      experimental-features = [ "nix-command" "flakes" "auto-allocate-uids" "cgroups" ];
      allowed-users = [ "@wheel" ];
      auto-allocate-uids = true;
      auto-optimise-store = true;
      keep-going = true;
      use-xdg-base-directories = true;
      use-cgroups = true;
    };

    registry = {
      tits.flake = self;
      nixpkgs.to = {
        type = "github";
        owner = "nixos";
        repo = "nixpkgs";
        inherit (self.inputs.nixpkgs) rev;
      };
    };

    nixPath = [ "nixpkgs=/etc/nix/channel" ];
    package = pkgs.lix;
  };

  fileSystems = {
    "/proc" = {
      device = "proc";
      fsType = "proc";
      options = [ "nosuid" "hidepid=invisible" "gid=1" ];
    };
  };

  hardware.bluetooth = {
    enable = true;
    settings.General.Experimental = true;
  };

  tits = {
    unfreeNames = [
      "p7zip"
      "aseprite"

      "dwarf-fortress"
      "spacefox-theme"
    ];

    persist = mkMerge [
      [

        "/var/cache/private/dnscrypt-proxy"
        "/var/cache/tuigreet"

        "/var/lib/libvirt"
        "/var/lib/NetworkManager"
        "/var/lib/nixos"
        "/var/lib/systemd"

        "/var/log"

        "/home/melinda/.android"
        "/home/melinda/.factorio"
        "/home/melinda/.librewolf"
        "/home/melinda/.ssh"
        "/home/melinda/.thunderbird"

        "/home/melinda/cfg"
        "/home/melinda/cod"
        "/home/melinda/doc"
        "/home/melinda/gay"
        "/home/melinda/gps"
        "/home/melinda/img"
        "/home/melinda/mem"
        "/home/melinda/org"
        "/home/melinda/rnd"
        "/home/melinda/sfx"
        "/home/melinda/mov"

        "/home/melinda/.cache/librewolf"
        "/home/melinda/.cache/nix"
        "/home/melinda/.cache/thunderbird"
        "/home/melinda/.cache/zsh"

        "/home/melinda/.config/aseprite"
        "/home/melinda/.config/dconf"
        "/home/melinda/.config/emacs"
        "/home/melinda/.config/obs-studio"
        "/home/melinda/.config/qBittorrent"
        "/home/melinda/.config/qalculate"
        "/home/melinda/.config/unity3d"
        "/home/melinda/.config/vesktop"
        "/home/melinda/.config/wivrn"

        "/home/melinda/.local/share/CKAN"
        "/home/melinda/.local/share/PrismLauncher"
        "/home/melinda/.local/share/Steam"
        "/home/melinda/.local/share/applications"
        "/home/melinda/.local/share/direnv"
        "/home/melinda/.local/share/flatpak"
        "/home/melinda/.local/share/mpd"
        "/home/melinda/.local/share/qBittorrent"
        "/home/melinda/.local/share/zoxide"
        "/home/melinda/.local/share/zathura"

        "/home/melinda/.local/state/syncthing"
        "/home/melinda/.local/state/wireplumber"
      ]
      {
        "/etc/NetworkManager/system-connections" = { m = "0700"; };
        "/var/lib/tailscale" = { m = "0700"; };
        "/var/lib/bluetooth" = { m = "0700"; };
      }
    ];
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

        prettypst = prev.prettypst.overrideAttrs (old: {
          patches = (old.patches or [ ]) ++ [
            ./prettypst-hline.patch
          ];
        });

        dwarf-fortress-peak = prev.dwarf-fortress-full.override (wrapper: rec {
          dfVersion = "0.47.05";

          df-games.dwarf-fortress_0_47_05 = wrapper.df-games.dwarf-fortress_0_47_05.override (game: {
            dfhack = game.dfhack.overrideAttrs (old: {
              preConfigure = (old.preConfigure or "") + ''
                grep -Ril cmake_minimum_required | xargs sed -Ei \
                  's|cmake_minimum_required\(.*\)|cmake_minimum_required(VERSION 3.10)|Ig'
                     
                sed -i 's|-Werror||' CMakeLists.txt
              '';
            });

            dwarf-therapist = game.dwarf-therapist.override (outer: {
              dwarf-therapist = outer.dwarf-therapist.overrideAttrs (old: {
                cmakeFlags = (old.cmakeFlags or [ ]) ++ [
                  "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
                ];
              });
            });

            settings.init = {
              INTRO = false;
              WINDOWED = false;
              FULLSCREENX = 1920;
              FULLSCREENY = 1080;
            };
          });

          theme = prev.dwarf-fortress-packages.themes.spacefox;
          enableFPS = true;
        });
      }
    )
  ];

  imports = [
    self.inputs.home-manager.nixosModules.home-manager
    ./dnscrypt.nix
    ./options.nix
    ./tmpfs.nix
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    kernelPackages = pkgs.linuxPackages_zen;
    zfs.package = pkgs.zfs_2_4;
    tmp.useTmpfs = true;
  };

  networking = {
    networkmanager.enable = true;
    useNetworkd = true;
  };

  time.timeZone = "Europe/Berlin";

  i18n = {
    defaultLocale = "en_US.UTF-8";

    extraLocaleSettings = {
      LC_COLLATE = "C.UTF-8";
      LC_TIME = "de_DE.UTF-8";
    };
  };

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

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDdkJo7RMoxUkuQ55YT1q5KANHrR+OJZzeYejpJW4rty nori"
  ];

  users.users.melinda = {
    shell = pkgs.zsh;
    isNormalUser = true;
    extraGroups = [ "wheel" "gamemode" "adbusers" "libvirtd" ];
    packages = with pkgs; [
      mindustry-wayland
      android-tools
      aseprite
      ckan
      cmatrix
      fastfetch
      feh
      ffmpeg
      file
      flameshot
      fzf
      grim
      hyfetch
      mpv
      playerctl
      pulsemixer
      qbittorrent
      self.inputs.keysmash.packages.${stdenv.system}.default
      swaybg
      thunderbird
      wl-clipboard
      yt-dlp
      zathura
      syncplay
      pwgen
    ];
    hashedPasswordFile = "/persist/secrets/melinda.pwhash";
  };

  environment = {
    systemPackages = with pkgs; [
      SDL2
      htop
      libnotify
      libqalculate
      lsof
      man-pages
      man-pages-posix
      nixpkgs-fmt
      nvtop
      p7zip-rar
      tree
      virt-manager
      wget
    ];

    etc = {
      "nixos".source = self;
      "nix/channel".source = self.inputs.nixpkgs.outPath;
    };

    sessionVariables = {
      EDITOR = "emacsclient -c";
    };
  };

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

    zsh = {
      enable = true;
      enableGlobalCompInit = false;
    };

    gamemode.enable = true;
  };

  services.openssh = {
    enable = true;

    settings = {
      KbdInteractiveAuthentication = false;
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };

    hostKeys = [{
      path = "/persist/etc/ssh/ssh_host_ed25519_key";
      type = "ed25519";
    }];
  };

  networking.firewall.enable = false; # TODO

  system.stateVersion = "25.11";

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
      xdg.configFile = {
        "flameshot/flameshot.ini".text = ''
          [General]
          useGrimAdapter=true
        '';

        "syncplay.ini".text = lib.generators.toINI { } {
          server_data = {
            host = "exit.bunny.vpn";
            port = 8999;
          };

          client_settings = {
            name = "Melinda Amanita, First Floret";
            room = "Absolutes Kinori";

            playerpath = pkgs.writeShellScript "mpv-gpu" ''
              exec ${getExe pkgs.mpv} --vo=gpu-next "$@"
            '';

            mediasearchdirectories = "['/home/melinda/mov']";
          };

          general = {
            checkforupdatesautomatically = false;
          };
        };

        "eza/theme.yml".text = builtins.toJSON {
          filenames = {
            # dot stuff in home
            ".android".icon.glyph = "";
            ".cache".icon.glyph = "󰃨";
            ".factorio".icon.glyph = "󰈏";
            ".icons".icon.glyph = "";
            ".librewolf".icon.glyph = "󰈹";
            ".local".icon.glyph = "󰆼";
            ".mozilla".icon.glyph = "󰈹";
            ".nv".icon.glyph = "󰢮";
            ".pki".icon.glyph = "󰌾";
            ".thunderbird".icon.glyph = "";
            ".zsh".icon.glyph = "";

            # main dirs in home
            "cfg".icon.glyph = "";
            "cod".icon.glyph = "";
            "doc".icon.glyph = "󰈙";
            "gay".icon.glyph = "󰺵";
            "gps".icon.glyph = "";
            "img".icon.glyph = "";
            "mem".icon.glyph = "";
            "org".icon.glyph = "";
            "rnd".icon.glyph = "󱗾";
            "sfx".icon.glyph = "";

            # misc
            ".jj".icon.glyph = "󰘬";
            "Caddyfile".icon.glyph = "󰒒";
            "result".icon.glyph = "";
          };

          extensions = {
            "excalidraw".icon.glyph = "";
            "gpx".icon.glyph = "";
            "json".icon.glyph = "";
            "key".icon.glyph = "󰌆";
            "ora".icon.glyph = "";
            "prettierrc".icon.glyph = "";
            "pug".icon.glyph = "";
            "yaml".icon.glyph = "";
          };
        };
      };

      imports = [
        "${self.inputs.aquaris}/module/home/emacs"
        ./emacs.nix
        ./tmux
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
            background-color = "#00000040";
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
        quickshell = {
          enable = true;
          systemd.enable = true;
          activeConfig = "/home/melinda/cfg/quickshell/shell.qml";
        };

        foot = {
          enable = true;
          settings = {
            colors.alpha = 0.0;
            main.include = "${pkgs.foot.themes}/share/foot/themes/gruvbox-dark";
          };
        };

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

        zoxide = {
          enable = true;
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

        zsh = let cache = "${config.xdg.cacheHome}/zsh"; in {
          enable = true;

          autosuggestion.enable = true;
          syntaxHighlighting.enable = true;

          autocd = true;
          defaultKeymap = "emacs";

          history = {
            append = true;
            extended = true;
            ignoreAllDups = true;

            path = "${cache}/history";
            save = 2147483647;
            size = 2147483647;
          };

          initContent = ''
            # help for builtins
            unalias run-help
            autoload run-help
            alias help=run-help

            bindkey "[1;3C" forward-word
            bindkey "[1;3D" backward-word

            # https://github.com/zsh-users/zsh-syntax-highlighting/issues/295#issuecomment-214581607
            zstyle ':bracketed-paste-magic' active-widgets '.self-*'
          '';

          plugins = with pkgs; [
            {
              name = "zsh-fzf-history-search";
              inherit (zsh-fzf-history-search) src;
            }
          ];

          oh-my-zsh = {
            enable = true;

            plugins = [
              "fancy-ctrl-z"
              "magic-enter"
            ];

            extraConfig = ''
              ZSH_COMPDUMP="${cache}/completion"
            '' + builtins.readFile ./zsh-cfg.sh;
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

        eza = {
          enable = true;
          extraOptions = [
            "--almost-all"
            "--group"
            "--group-directories-first"
            "--header"
            "--icons"
            "--long"
            "--mounts"
          ];
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
          cd = "z";

          ephemeral = "sudo find / -xdev -type f | less";

          yoink = builtins.concatStringsSep " " [
            "yt-dlp"
            "--cookies-from-browser=firefox:~/.librewolf/9ucptchv.default-default"
            "--extract-audio --embed-metadata "
            "--output='%(playlist_index)02d - %(title)s.%(ext)s'"
          ];

          sneeptime = "systemctl suspend";
          work = "sudo nixos-rebuild switch --flake /home/melinda/cfg -L";
          crush = "nix store gc -v";
          judgement = "systemctl --user restart emacs";
          thy-end-is-now = "sudo nix-env --delete-generations +3 --profile /nix/var/nix/profiles/system";
          emacs = "emacsclient -nc";

          "branch-delete" = "jj bookmark delete";
          "jjfetch" = "jj git fetch --all-remotes"; # "pull"
          "branch-move" = "jj bookmark set";
          "branch-push" = "jj git push --all --deleted"; # jps is intelligent push
          "jjrebase" = "jj rebase";
          "branch-show" = "jj bookmark list --no-pager";
          "branch-showoff" = "jj bookmark list --all --no-pager";
          "branch-sync" = "jj bookmark track";
          "commit-blame" = "jj file annotate";
          "commit-delete" = "jj abandon";
          "commit-deletemark" = "jj tag delete";
          "jjdescribe" = "jj describe -m";
          "jjdescribeagain" = "jj describe --edit";
          "commit-diff" = "jj diff";
          "commit-diff-git" = "jj diff --git";
          "commit-duplicate" = "jj duplicate";
          "jjeditc" = "jj edit";
          "commit-listmarks" = "jj tag list --no-pager";
          "commit-makeinverted" = "jj restore";
          "commit-makeinverted-better" = "jj restore -i";
          "commit-mark" = "jj tag set --allow-move";
          "jjnewc" = "jj new";
          "jjshowc" = "jj show";
          "commit-show-git" = "jj show --git";
          "commit-showlastready" = "jj show $(jfc)";
          "jjsplit" = "jj split";
          "jjsquish" = "jj squash";
          "jjsquishhard" = "jj squash -i";
          "commit-stat" = "jj show --stat";
          "file-forget" = "jj file untrack";
          "file-list" = "jj file list";
          "file-show" = "jj file show";
          "jjclone" = "jj git clone --colocate";
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
