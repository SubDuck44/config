{ config, lib, pkgs, ... }:
let
  inherit (lib) mkAfter getExe;
in
{
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
  };

  programs = {
    librewolf = {
      enable = true;
      settings."privacy.resistFingerprinting" = false;
    };

    vesktop = {
      enable = true;
    };

    fuzzel = {
      enable = true;
    };

    git = {
      enable = true;
    };

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
    plugins = with pkgs.hyprlandPlugins; [
      hyprexpo
    ];
    extraConfig = builtins.readFile ./hyprland.conf;
  };
}
