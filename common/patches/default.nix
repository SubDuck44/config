{ self, lib, ... }: {
  nixpkgs.overlays = lib.singleton (_: prev:
    let obscura = self.inputs.obscura.packages.${prev.stdenv.system}; in {
      inherit (obscura)
        keysmash
        yellowcake
        ;

      inherit (obscura.nvidia.entries) nvtop;

      nix-output-monitor = prev.nix-output-monitor.overrideAttrs {
        version = "2.1.8-unstable-2026-05-22";

        src = prev.fetchFromGitHub {
          owner = "maralorn";
          repo = "nix-output-monitor";
          rev = "0e855e51c1700e35456faa3dee2e50024f602f42";
          hash = "sha256-8viiPvLkj0vFdG1kgcNuKXoenyTBvKd+GQ62jwbONns=";
        };
      };

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

      syncplay = prev.syncplay.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [
          (prev.fetchpatch {
            url = "https://github.com/Syncplay/syncplay/pull/754.diff";
            hash = "sha256-m+IpZ6b0G1r5pc+s3gR5KqgKmfINlp/vJipLprqxtHY=";
          })
          ./syncplay.patch
        ];

        postFixup = (old.postFixup or "") + ''
          rm $out/share/applications/syncplay-server.desktop
          sed -Ei 's|(Exec=syncplay .*)|\1 --no-store|' \
            $out/share/applications/syncplay.desktop
        '';
      });
    });
}
