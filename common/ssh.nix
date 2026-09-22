{ pkgs, lib, config, utils, ... }: {
  environment.systemPackages = with pkgs; [
    sshfs
  ];

  programs.ssh.knownHosts = {
    "exit.bunny.vpn".publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBbsL7HyOCM56ejtlWqEBG1YzQwX2KmZ3S5KzoGnWh/j";
  };

  systemd =
    let
      dst = "/home/melinda/bunny/mnt";
      pfx = utils.escapeSystemdPath dst;
    in
    {
      mounts = [{
        name = "${pfx}.mount";
        what = "mel@exit.bunny.vpn:";
        where = dst;
        type = "fuse.sshfs";
        options = lib.join "," [
          "port=18213"
          "_netdev"
          "nosuid"
          "rw"
          "allow_other"
          "default_permissions"
          "follow_symlinks"
          "identityfile=${config.aquaris.secret "user/melinda/ssh/main"}"
          "uid=1000"
          "gid=100"
        ];
      }];

      automounts = [{
        name = "${pfx}.automount";
        where = dst;
        wantedBy = [ "multi-user.target" ];
      }];
    };

  home-manager.sharedModules = [{
    programs.ssh.settings = {
      "bunny" = {
        HostName = "exit.bunny.vpn";
        Port = 18213;
        User = "mel";
      };
    };
  }];
}
