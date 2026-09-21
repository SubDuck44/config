{ pkgs, ... }: {
  home-manager.sharedModules = [{
    xdg = {
      portal = {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-hyprland
          xdg-desktop-portal-gtk
        ];
      };

      systemDirs.data = with pkgs; map glib.getSchemaDataDirPath [
        gsettings-desktop-schemas
        gtk3
      ];

      configFile."xkb/symbols/spanish".text = ''
        xkb_symbols "basic" {
          include "de(nodeadkeys)"
          replace key <AC01> {[a, A, aacute, Aacute]};
          replace key <AD03> {[e, E, eacute, Eacute]};
          replace key <AD08> {[i, I, iacute, Iacute]};
          replace key <AD09> {[o, O, oacute, Oacute]};
          replace key <AD07> {[u, U, uacute, Uacute]};
          replace key <AB06> {[n, N, ntilde, Ntilde]};
        };
      '';
    };

    aquaris.hyprland = {
      enable = true;
      precfg = builtins.readFile ./lib.lua;

      env = {
        HYPRCURSOR_SIZE = "24";
        XCURSOR_SIZE = "24";

        GDK_BACKEND = "wayland";
        QT_QPA_PLATFORM = "wayland";
        SDL_VIDEODRIVER = "wayland";

        NIXOS_OZONE_WL = "1";
        _JAVA_AWT_WM_NON_REPARENTING = "1";
      };

      settings = {
        config = {
          general = {
            gaps_in = 3;
            gaps_out = 3;
            border_size = 2;

            col = {
              active_border = {
                colors = [
                  "rgba(bdae93ff)"
                  "rgba(a89984ff)"
                ];

                angle = 45;
              };

              inactive_border = {
                colors = [
                  "rgba(282828ee)"
                  "rgba(32302fee)"
                ];

                angle = 45;
              };
            };

            layout = "dwindle";
          };

          decoration = {
            rounding = 4;
            rounding_power = 2;

            active_opacity = 1.0;
            inactive_opacity = 1.0;

            blur = {
              enabled = true;
              size = 4;
              passes = 1;
              brightness = 0.7;
              vibrancy = 0.0;

              new_optimizations = true;
            };
          };

          animations = {
            enabled = true;
          };

          dwindle = {
            preserve_split = true;
          };

          ecosystem = {
            no_update_news = true;
            no_donation_nag = true;
          };

          misc = {
            force_default_wallpaper = -1;
            disable_hyprland_logo = true;
            on_focus_under_fullscreen = 2;
            enable_swallow = true;
            swallow_regex = "foot";
            initial_workspace_tracking = 1;
            enable_anr_dialog = false;
          };

          input = {
            kb_layout = "de";
            kb_variant = "nodeadkeys";
            kb_options = "compose:ins";

            repeat_rate = 50;
            repeat_delay = 250;

            follow_mouse = 1;

            sensitivity = 0;

            touchpad = {
              natural_scroll = false;
            };
          };

          plugin = {
            dynamic_cursors = {
              enabled = true;
              mode = "stretch";

              shake = {
                enabled = true;
                effects = true;
              };
            };

            hyprfocus = {
              keyboard_focus_animation = "flash";
              mouse_focus_animation = "flash";
              fade_opacity = 0.9;
              only_on_monitor_change = true;
            };
          };
        };
      };

      animations = f: with f; {
        global = { speed = 10; curve = bezier "default"; };
        border = { speed = 5.39; curve = bezier "easeOutQuint"; };
        windows = { speed = 1.0; curve = bezier "linear"; style = "gnomed"; };
        windowsIn = { speed = 1.0; curve = bezier "linear"; style = "gnomed"; };
        windowsOut = { speed = 1.0; curve = bezier "linear"; style = "gnomed"; };
        fadeIn = { speed = 1.73; curve = bezier "easeOutQuint"; };
        fadeOut = { speed = 1.46; curve = bezier "easeOutQuint"; };
        layers = { speed = 3.81; curve = bezier "linear"; };
        layersIn = { speed = 4; curve = bezier "linear"; style = "fade"; };
        layersOut = { speed = 1.5; curve = bezier "linear"; style = "fade"; };
        fadeLayersIn = { speed = 1.79; curve = bezier "almostLinear"; };
        fadeLayersOut = { speed = 1.39; curve = bezier "almostLinear"; };
        workspaces = { speed = 1.94; curve = bezier "almostLinear"; };
        workspacesIn = { speed = 1.21; curve = bezier "almostLinear"; };
        workspacesOut = { speed = 1.94; curve = bezier "almostLinear"; };
        zoomFactor = { speed = 7; curve = bezier "quick"; };
      };

      curves = f: with f; {
        easeOutQuint = bezier {
          points = [
            [ 0.23 1.00 ]
            [ 0.32 1.00 ]
          ];
        };

        easeInOutCubic = bezier {
          points = [
            [ 0.65 0.05 ]
            [ 0.36 1.00 ]
          ];
        };

        linear = bezier {
          points = [
            [ 0.00 0.00 ]
            [ 1.00 1.00 ]
          ];
        };

        almostLinear = bezier {
          points = [
            [ 0.50 0.50 ]
            [ 0.75 1.00 ]
          ];
        };

        quick = bezier {
          points = [
            [ 0.15 0.00 ]
            [ 0.10 1.00 ]
          ];
        };

        easy = spring {
          mass = 1;
          stiffness = 71.2633;
          dampening = 15.8273644;
        };
      };

      windowRules = [
        {
          name = "fix-xwayland-drags";
          match = {
            class = "^$";
            title = "^$";
            xwayland = true;
            float = true;
            fullscreen = false;
            pin = false;
          };

          no_focus = true;
        }
        {
          name = "fix-popups";
          match.modal = true;

          no_initial_focus = false;
          float = true;
          pin = true;
          decorate = false;
          border_size = 0;
          rounding = 0;
          move = [ 0 0 ];
        }
        {
          name = "undecorate-steam-launching-popup";
          match.title = "Launching...";

          decorate = false;
          no_initial_focus = true;
          no_follow_mouse = true;
        }
        {
          name = "floating-windows";
          match.float = true;
          animation = "slide top";
        }
        {
          name = "fix-flameshot";
          match.title = "flameshot";
          float = true;
        }
        {
          name = "smart-gaps";
          match = { float = false; workspace = "w[tv1]"; };

          border_size = 0;
          rounding = 0;
        }
      ];

      workspaceRules = [
        {
          workspace = "1";
          monitor = "DP-6";
          default = true;
        }
        {
          workspace = "101";
          monitor = "DP-5";
          default = true;
        }
        {
          workspace = "w[tv1]";
          gaps_out = 0;
          gaps_in = 0;
        }
      ];

      binds = f: with f; {
        ##### programs #####
        Return = function "terminal()";
        S-Return = execR "foot" { floating = true; };

        e = exec "emacsclient -nc";
        x = exec "fuzzel";
        i = exec "foot htop";
        m = execR "foot ncmpcpp" { floating = true; };
        p = execR "foot pulsemixer" { floating = true; };
        w = exec "librewolf";

        ##### kill things #####
        q = function ''
          window = hl.get_active_window()
          if window.class == "librewolf" and window.initial_title == "LibreWolf" then
            hl.dispatch(hl.dsp.send_shortcut({
              mods = "CTRL",
              key = "q",
              window = window,
            }))
          else
            hl.dispatch(hl.dsp.window.close())
          end
        '';

        S-q = function ''
          hl.dispatch(hl.dsp.window.kill())
        '';

        ##### fullscreen #####
        f = fullscreen 1 0;
        C-f = fullscreen 2 2;
        A-f = fullscreen 0 2;

        ##### media keys #####
        XF86AudioLowerVolume = raw (exec "wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%-");
        XF86AudioRaiseVolume = raw (exec "wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%+");
        XF86AudioMute = raw (exec "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle");
        XF86AudioMicMute = raw (exec "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle");
        XF86AudioPlay = raw (exec "mpc toggle");
        XF86AudioPrev = raw (exec "mpc prev");
        XF86AudioNext = raw (exec "mpc next");
        XF86MonBrightnessDown = raw (exec "brightnessctl set 10%-");
        XF86MonBrightnessUp = raw (exec "brightnessctl set 10%+");

        ##### misc ######
        Print = raw (exec "flameshot gui -r | wl-copy");

        "code:47" = dsp ''
          send_shortcut({mods = " ctrl ", key = " code:47 ", window = " class: ^(com\\.obsproject\\.Studio)$"})
        '';

        v = dsp ''window.float({ "toggle" })'';

        "mouse:272" = dsp "window.drag()";
        "mouse:273" = dsp "window.resize()";

        S-m = function ''
          mouse_active = not mouse_active
          hl.device({ name = "razer-razer-basilisk-v3", enabled = mouse_active })
          hl.device({ name = "elan0307:00-04f3:3282-touchpad", enabled = mouse_active })
        '';

        S-s = function ''
          if hl.get_config("input.kb_layout") == "de" then
            hl.notification.create({
              text = "Spanish mode",
              duration = 2000,
              icon = "info",
              color = "#fe8019",
            })

            hl.config({
              input = {
                kb_layout = "spanish",
                kb_variant = "",
              },
            })
          else
            hl.notification.create({
              text = "German mode",
              duration = 2000,
              icon = "info",
              color = "#83e598",
            })

            hl.config({
              input = {
                kb_layout = "de",
                kb_variant = "nodeadkeys",
              },
            })
          end
        '';
      };
    };

    wayland.windowManager.hyprland.plugins = with pkgs.hyprlandPlugins; [
      hyprfocus
      hypr-dynamic-cursors
    ];
  }];
}
