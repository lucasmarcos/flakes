{
  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      packages.${system} = {
        veyon = pkgs.qt6.callPackage ./veyon { };

        apk-tools-static-bin = pkgs.callPackage ./alpine/apk-tools-static-bin.nix { };
        alpine-keys = pkgs.callPackage ./alpine/alpine-keys.nix { };
        busybox-static-bin = pkgs.callPackage ./alpine/busybox-static-bin.nix { };
        build-alpine-rootfs = pkgs.callPackage ./alpine/build-alpine-rootfs.nix {
          apk-tools = self.outputs.packages.${system}.apk-tools-static-bin;
          alpine-keys = self.outputs.packages.${system}.alpine-keys;
        };

        build-archlinux-rootfs = pkgs.callPackage ./archlinux/build-archlinux-rootfs.nix { };
        build-steam-rootfs = pkgs.callPackage ./steam/build-steam-rootfs.nix { };

        lan-mouse-bin-fhs-env = pkgs.callPackage ./lan-mouse-bin/lan-mouse-bin-fhs-env.nix { };
        zen-bin-fhs-env = pkgs.callPackage ./zen-bin/zen-bin-fhs-env.nix { };

        bun-bin-fhs-env = pkgs.buildFHSEnv {
          name = "bun-bin-fhs-env";
          runScript = "$HOME/.local/bin/bun";
        };

        aspell-pt-br = pkgs.aspellWithDicts (d: [ d.pt_BR ]);
        wine-bin-fhs-env = pkgs.callPackage ./wine-bin-fhs-env.nix { };

        dhall-bin-fhs-env = pkgs.buildFHSEnv {
          name = "dhall-bin-fhs-env";
          targetPkgs =
            pkgs: with pkgs; [
              zlib
              ncurses
              gmp
            ];
          runScript = "bash";
        };
      };
    };
}
