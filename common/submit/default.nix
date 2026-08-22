{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    (writeShellApplication {
      name = "submit";
      text = builtins.readFile ./submit.sh;
      runtimeInputs = [
        swaks
        yq-go
      ];
    })
  ];
}
