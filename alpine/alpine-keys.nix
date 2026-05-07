{ fetchurl }:
let
  mirror = "dl-cdn.alpinelinux.org";
  branch = "edge";
  repo = "main";
  arch = "x86_64";
  version = "2.6";
  rev = "r0";
  pname = "alpine-keys";
in
fetchurl {
  url = "https://${mirror}/${branch}/${repo}/${arch}/${pname}-${version}-${rev}.apk";
  hash = "sha256-RBNfSnGQcbfEOfFQPr+7IhaJlDDxENWxV5p+DWU0094=";
}
