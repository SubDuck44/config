{ self, lib, ... }: {
  nixpkgs.overlays = lib.singleton (next: prev:
    let obscura = self.inputs.obscura.packages.${prev.stdenv.system}; in
    self.inputs.obscura.lib.infuse prev ({
      prettypst.__assign = obscura.my-prettypst;

      hyprlandPlugins.imgborders.__output = {
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

        nativeBuildInputs.__append = with prev; [
          breakpointHook
        ];
      };

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

      deadname-remover.__assign = next.bun2nix.mkDerivation (drv: {
        pname = "deadname-remover";
        version = "2.3.1";

        src = prev.fetchFromGitHub {
          owner = "arimgibson";
          repo = drv.pname;
          rev = "4a791d744e4efeffdfdf55cc8faacd5648d5ba59";
          hash = "sha256-o5TNmm6gV12xYCtscVaCYMGkU+dWlJ3zce5/RjDcbAQ=";
        };

        patches = [
          ./deadname-remover/disable-url-validation.patch
        ];

        bunDeps = next.bun2nix.fetchBunDeps {
          bunNix = ./deadname-remover/bun.nix;
        };

        buildPhase = ''
          bun run zip:firefox
        '';

        installPhase = ''
          install -Dm644 .output/${drv.pname}-${drv.version}-firefox.zip $out
        '';
      });

    } // builtins.mapAttrs (_: x: { __assign = x; }) {
      inherit (obscura)
        avahi-proxy
        bun2nix
        keysmash
        yellowcake
        ;

      inherit (obscura.nvidia.entries) nvtop;
    }));
}
