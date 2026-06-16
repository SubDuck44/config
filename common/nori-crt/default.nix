{ pkgs, lib, config, ... }:
let
  inherit (lib)
    pipe
    getExe
    ;
in
{
  security.pki.certificateFiles = [ (builtins.path { path = ./main.crt; }) ];

  environment.variables.JAVAX_NET_SSL_TRUSTSTORE = pipe pkgs.python3 [
    (x: x.withPackages (p: with p; [ pyjks ]))
    (x: pkgs.runCommand "java-truststore" { } ''
      ${getExe x} ${./keystore.py} \
        ${config.environment.etc."ssl/certs/ca-bundle.crt".source} \
        $out
    '')
  ];
}
