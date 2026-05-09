{
  stdenvNoCC,
  fetchurl,
  libarchive,
}:
let
  mirror = "dl-cdn.alpinelinux.org";
  branch = "edge";
  repo = "main";
  arch = "x86_64";
  version = "3.0.6";
  rev = "r0";
  pname = "apk-tools-static";
in
stdenvNoCC.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://${mirror}/${branch}/${repo}/${arch}/${pname}-${version}-${rev}.apk";
    hash = "sha256-Ej/oT75LkAyZIfmx7Gen9makC5P8tYSOZ97wjFnnNok=";
  };

  nativeBuildInputs = [ libarchive ];

  unpackCmd = "bsdtar -x -f $src";

  postInstall = ''
    mkdir -p $out/bin
    mv apk.static $out/bin/apk
  '';
}
