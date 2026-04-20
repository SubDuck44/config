{ self, lib, ... }: {
  nixpkgs.overlays = lib.singleton (_: prev:
    let obscura = self.inputs.obscura.packages.${prev.stdenv.system}; in {
      inherit (obscura)
        keysmash
        yellowcake
        ;

      inherit (obscura.nvidia.entries) nvtop;

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
