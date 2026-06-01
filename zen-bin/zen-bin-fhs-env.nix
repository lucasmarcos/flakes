{ buildFHSEnv }:
buildFHSEnv {
  name = "zen-bin-fhs-env";
  targetPkgs =
    pkgs: with pkgs; [
      gtk3
      alsa-lib
      libX11
      libxcb
      libxi
      libxcursor
      xrandr
    ];
  runScript = "bash";
}
