{ config, lib, self, ... }:
let
  inherit (lib)
    attrsToList
    elemAt
    filterAttrs
    flatten
    flip
    head
    ifEnable
    join
    length
    listToAttrs
    mapAttrs
    match
    mergeAttrsList
    mkOption
    pipe
    splitString
    sublist
    tail;

  inherit (lib.types)
    attrsOf
    bool
    coercedTo
    listOf
    str
    submodule;

  root = "/persist";
  cfg = filterAttrs (_: x: x.e) config.tits.persist;

  entry = submodule ({ name, ... }:
    let user = safeHead (match "/home/([^/]+)/.+" name); in {
      options = {
        e = mkOption {
          description = "Enable";
          type = bool;
          default = true;
        };

        m = mkOption {
          description = "Mode";
          type = str;
          default = "0755";
        };

        u = mkOption {
          description = "User/UID";
          type = str;
          default = if user == null then "root" else user;
        };

        g = mkOption {
          description = "Group/GID";
          type = str;
          default = if user == null then "root" else "users";
        };
      };
    });

  safeHead = l: if l == null then null else head l;

  parents = dir:
    let
      helper = parts: if parts == [ ] then [ ] else
      [ (join "/" parts) ] ++ helper (sublist 0 (length parts - 1) parts);
    in
    tail (helper (splitString "/" dir));
in
{
  options.tits.persist = mkOption {
    type = (coercedTo (listOf str) (flip pipe [
      (map (d: { name = d; value = { }; }))
      listToAttrs
    ])) (attrsOf entry);

    default = [ ];
  };

  config = {
    fileSystems = pipe cfg [
      (mapAttrs (d: x: {
        device = "${root}/${d}";
        options = [ "bind" ];
      }))
      (x: x // {
        ${root}.neededForBoot = true;

        "/" = {
          fsType = "tmpfs";
          options = [ "nosuid" "mode=755" ];
        };
      })
    ];

    systemd.tmpfiles.settings."persist" = pipe cfg [
      attrsToList
      (map
        ({ name, value }:
          let
            capture = match "(/home/[^/]+)/(.+)" name;
            homeDir = elemAt capture 0;
            userDir = elemAt capture 1;
          in
          [{
            "${root}/${name}"."d" = {
              mode = value.m;
              user = value.u;
              group = value.g;
            };
          }] ++ (if capture == null then [ ] else
          pipe userDir [
            parents
            (map (d: {
              "${root}/${homeDir}/${d}"."d" = {
                user = value.u;
                group = value.g;
              };

              "${homeDir}/${d}"."d" = {
                user = value.u;
                group = value.g;
              };
            }))
          ])))
      flatten
      mergeAttrsList
    ];
  };
}

