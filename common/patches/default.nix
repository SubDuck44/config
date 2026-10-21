{ config, self, lib, ... }: {
  nixpkgs.overlays = lib.singleton (_: prev:
    let
      inherit (prev.stdenv) system;
      obscura = self.inputs.obscura.packages.${system};
      blender-cuda = self.inputs.blender-cuda.packages.${system};
    in
    self.inputs.obscura.lib.infuse prev ({
      lixPackageSets.latest.__assign = prev.lixPackageSets.lix_2_96;
      lix.__assign = prev.lixPackageSets.lix_2_96.lix;

      hyprlandPlugins = {
        hypr-dynamic-cursors.__output = {
          version.__assign = "0-unstable-2026-08-06";

          src.__output = {
            rev.__assign = "5a224284872208b5324759d535d65061043725de";
            hash.__assign = "sha256-BQjuQplkQFA30/7evDxmEAvr2ArIG09JffEBQhuzo80=";
          };

          enableParallelBuilding.__assign = true;
        };
      };

      # TODO https://github.com/NixOS/nixpkgs/issues/576406
      linuxPackages_zen.__extend.v4l2loopback.__assign =
        prev.runCommand "v4l2loopback-fix" { } ''
          subdir=lib/modules/${config.boot.kernelPackages.kernel.modDirVersion}
          mkdir -p $out/$subdir
          cd ${prev.linuxPackages_zen.v4l2loopback}/$subdir
          for f in *; do
            if [[ $f =~ ^modules ]]; then continue; fi
            cp -r $f $out/$subdir/$f
          done
        '';

      #################### PERMANENT ####################

      blender.__assign = blender-cuda.blender-with-cuda-unstable;

      gomuks-web .__assign = obscura.my-gomuks-web;
      prettypst  .__assign = obscura.my-prettypst;
      tuigreet   .__assign = obscura.my-tuigreet;

      factorio-space-age.__input.makeDesktopItem.__hijack.exec.__prepend = "gamemoderun ";

      syncplay.__output = {
        patches.__append = [
          ./syncplay.patch
        ];

        postFixup.__append = ''
          rm $out/share/applications/syncplay-server.desktop
          sed -Ei 's|(Exec=syncplay.*)|\1 --no-store|' \
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
