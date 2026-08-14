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
        (pkgs.writeShellScriptBin "hrtrack" ''
          #!/usr/bin/env bash
          set -euo pipefail

          # only activate in the evening
          hour="$(date +%-H)"
          if ((4 < hour && hour < 20)); then exit; fi

          extra=""
          if (($(date +%s) / 86400 % 6 == 0)); then
          	extra=" and Cypro"
          fi

          mesg="$(printf 'Take Estrogen%s!' "$extra")"
          echo -e 'Done\0icon\x1fhrtrack' | fuzzel -d \
          	--mesg "$mesg" --mesg-mode expand \
          	--message-color '#ebdbb2ff' \
          	--hide-prompt --minimal-lines
        '')
        # mindustry-wayland
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
        mpv
        nvtop
        openttd
        p7zip-rar
        pcmanfm
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
        gucharmap

        (greenfoot.overrideAttrs (old: {
          installPhase = lib.replaceString "UNNAMED" "UNNAMED --add-opens javafx.graphics/com.sun.javafx.scene.input=ALL-UNNAMED" old.installPhase;
        }))
      ];

      shellAliases = {
        shutdown = "hrtrack; sudo poweroff";
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
          colors-dark = {
            alpha = 0.0;
            blur = true;
          };
          main = {
            font = "monospace:size=10.5";
            include = "${pkgs.foot.themes}/share/foot/themes/gruvbox-dark";
          };
        };
      };

      fuzzel = {
        enable = true;

        settings = {
          colors = {
            background = "282828A0";
            text = "ebdbb2ff";
            placeholder = "83a598ff";
            input = "83a598ff";
            selection = "928374ff";
            selection-text = "fbf1c7ff";
            match = "fbf1c7ff";
          };
        };
      };
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
      ".config/openttd" = { };

      ".local/share/CKAN" = { };
      ".local/share/Mindustry" = { };
      ".local/share/applications" = { };
      ".local/share/chatterino" = { };
      ".local/share/qBittorrent" = { };
      ".local/share/typst/packages/local" = { };
      ".local/share/umu" = { };
      ".local/share/openttd" = { };

      ".local/state/syncthing" = { };
    };

    xdg = {
      configFile."equibop-flags.conf".text = ''
        --wayland
        --force_high_performance_gpu
      '';

      mimeApps = {
        enable = true;
        defaultApplicationPackages = with pkgs; [ pcmanfm ];
      };
    };
  });
}
