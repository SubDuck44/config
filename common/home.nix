{ pkgs, lib, config, ... }: {
  aquaris = {
    unfreeNames = [
      "p7zip"
    ];
  };

  home-manager.sharedModules = lib.singleton (hm: {
    home = {
      stateVersion = "25.11";

      packages = with pkgs; [
        chatterino7
        ckan
        cmatrix
        equibop
        espeak
        feh
        ffmpeg
        godot
        keysmash
        libnotify
        libqalculate
        mindustry-wayland
        mpv
        nvtop
        p7zip-rar
        pcsx2
        pixelorama
        playerctl
        poppler-utils
        pulsemixer
        pwgen
        qbittorrent
        steamguard-cli
        swaybg
        thunderbird
        umu-launcher
        wl-clipboard
      ];

      shellAliases = {
        auto = "espeak -p 0 -P 0";
        sneeptime = "systemctl suspend";
        crush = "nix store gc -v";
        judgement = "systemctl --user restart emacs";
        thy-end-is-now = "sudo nix-env --delete-generations +3 --profile /nix/var/nix/profiles/system";
        emacs = "emacsclient -nc";
      };

      sessionVariables = {
        NIXOS_CONFIG_DIR = ''$(realpath "$HOME/cfg")'';
      };
    };

    services = {
      syncthing.enable = true;

      hyprsunset.enable = true;
    };

    systemd.user.services.wlsunset = {
      Install.WantedBy = [ "graphical-session.target" ];

      Unit = {
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service.ExecStart = lib.mkForce [
        (lib.getExe (pkgs.writeShellApplication {
          name = "wlsunset-via-hyprsunset";

          runtimeInputs = with pkgs; [
            hyprland
            wlsunset
          ];

          text = ''
            wlsunset -l 54 -L 10 |& sed -Enu        \
              's|.* ([0-9]+) K|hyprctl hyprsunset temperature \1|p' \
            | bash -x
          '';
        }))
      ];
    };

    programs = {
      foot = {
        enable = true;
        settings = {
          colors-dark.alpha = 0.0;
          main.include = "${pkgs.foot.themes}/share/foot/themes/gruvbox-dark";
        };
      };

      fuzzel.enable = true;
    };

    aquaris.git.sshKeyFile = _: config.aquaris.secret "user/${hm.config.home.username}/ssh/main";
    aquaris.persist = {
      "cfg" = { };
      "cod" = { };
      "doc" = { };
      "gay" = { };
      "gps" = { };
      "img" = { };
      "mem" = { };
      "mov" = { };
      "org" = { };
      "rnd" = { };
      "sfx" = { };

      ".thunderbird" = { };

      ".cache/thunderbird" = { };

      ".config/PCSX2" = { };
      ".config/aseprite" = { };
      ".config/dconf" = { };
      ".config/equibop" = { };
      ".config/qBittorrent" = { };
      ".config/qalculate" = { };
      ".config/steamguard-cli" = { };

      ".local/share/CKAN" = { };
      ".local/share/Mindustry" = { };
      ".local/share/applications" = { };
      ".local/share/chatterino" = { };
      ".local/share/qBittorrent" = { };
      ".local/share/umu" = { };

      ".local/state/syncthing" = { };
    };

    xdg.configFile."equibop-flags.conf".text = ''
      --wayland
    '';
  });
}
