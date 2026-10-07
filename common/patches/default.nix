{ self, lib, ... }: {
  nixpkgs.overlays = lib.singleton (_: prev:
    let obscura = self.inputs.obscura.packages.${prev.stdenv.system}; in
    self.inputs.obscura.lib.infuse prev ({
      wivrn.__output = {
        buildInputs.__append = with prev; [ sdl2-compat ];
        cmakeFlags.__append = [ "-DWIVRN_FEATURE_DEBUG_GUI=ON" ];
        postPatch.__append = ''
          sed -i '/XRT_FEATURE_WINDOW_PEEK/s|OFF|ON|p' server/CMakeLists.txt
        '';
      };

      hyprlandPlugins = {
        imgborders.__output = {
          version.__assign = "2.0.0-unstable-2026-08-16";

          src.__output = {
            rev.__assign = "08be22236144d3c91607bcfa955ed0d457f4f50b";
            hash.__assign = "sha256-O+896T2qrisxiWTotB5HlzKw8XEJqPDTgSUHAAVUD18=";
          };

          strictDeps.__assign = true;

          prePatch.__append = ''
            sed -i \
              -e '/VERSION_RAW/d' \
              -e '6aset(VERSION 2.0.0)' \
              CMakeLists.txt
          '';
        };

        hypr-dynamic-cursors.__output = {
          version.__assign = "0-unstable-2026-08-06";

          src.__output = {
            rev.__assign = "5a224284872208b5324759d535d65061043725de";
            hash.__assign = "sha256-BQjuQplkQFA30/7evDxmEAvr2ArIG09JffEBQhuzo80=";
          };

          enableParallelBuilding.__assign = true;
        };
      };

      #################### PERMANENT ####################

      gomuks-web .__assign = obscura.my-gomuks-web;
      prettypst  .__assign = obscura.my-prettypst;

      factorio-space-age.__input.makeDesktopItem.__hijack.exec.__prepend = "gamemoderun ";

      syncplay.__output = {
        patches.__append = [
          ./syncplay.patch
        ];

        postFixup.__append = ''
          rm $out/share/applications/syncplay-server.desktop
          sed -Ei 's|(Exec=syncplay .*)|\1 --no-store|' \
            $out/share/applications/syncplay.desktop
        '';
      };
    } // builtins.mapAttrs (_: x: { __assign = x; }) {
      inherit (obscura)
        bun2nix
        keysmash
        molecule
        yellowcake
        ;

      inherit (obscura.nvidia.entries) nvtop;
    }));
}
