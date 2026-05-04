{
  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      packages.${system} = {
        veyon = pkgs.callPackage ./veyon { };

        apk-tools-static-bin = pkgs.callPackage ./alpine/apk-tools-static-bin.nix {};
        busybox-static-bin = pkgs.callPackage ./alpine/busybox-static-bin.nix {};
        build-alpine-rootfs = pkgs.callPackage ./alpine/build-alpine-rootfs.nix {
          apk-tools = self.outputs.packages.${system}.apk-tools-static-bin;
        };
      };
    };
}
