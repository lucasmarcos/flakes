{ buildFHSEnv }:
buildFHSEnv {
  name = "lan-mouse-bin-fhs-env";
  targetPkgs =
    pkgs: with pkgs; [
      freetype
      wayland
   ];
  runScript = "bash";
}
