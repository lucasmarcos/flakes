{ stdenvNoCC, fetchurl }:
let
  version = "1.30.0";
in
stdenvNoCC.mkDerivation {
  pname = "apk-tools-static";
  inherit version;

  src = fetchurl {
    url = "https://busybox.net/downloads/binaries/${version}-x86_64-linux-musl/busybox";
    hash = "sha256-bhI+fzICqMHpsflNiUFYCiUTU4K5no0+NPuFi7oxE0g=";
  };

  dontUnpack = true;

  postInstall = ''
    mkdir -p "$out/bin"
    cp "$src" "$out/bin/busybox"
  '';
}
