{
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings.main = {
        capslock = "layer(control)";
        "leftshift+leftmeta+f23" = "layer(meta)"; # remap useless copilot key
      };
    };
  };
}
