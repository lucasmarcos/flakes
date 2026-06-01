{ buildFHSEnv }:
buildFHSEnv {
  name = "lan-mouse-bin-fhs-env";
  targetPkgs =
    pkgs: with pkgs; [
      gtk4
      glib
      libadwaita
      libxtst
      libx11
    ];
  runScript = "bash";
}
