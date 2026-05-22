{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  ninja,
  lzo,
  openldap,
  cyrus_sasl,
  pam,
  procps,
  libvncserver,
  libxrandr,
  libfakekey,
  libxinerama,
  libxdamage,
  libxcursor,
  systemd,
  qttools,
  qt5compat,
  qthttpserver,
  wrapQtAppsHook,
  qt6Packages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "veyon";
  version = "4.10.3";
  src = fetchFromGitHub {
    owner = "veyon";
    repo = "veyon";
    rev = "v${finalAttrs.version}";
    hash = "sha256-nc30xn7nEkhM43BH81YBDcxehAZ7Ee+qgYJ6ogDAdRw=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    qt5compat
    qt6Packages.qca
    lzo
    openldap
    cyrus_sasl
    pam
    procps
    libvncserver
    libxrandr
    libfakekey
    libxinerama
    libxdamage
    libxcursor
    qthttpserver
    systemd
  ];

  cmakeFlags = [
    (lib.cmakeFeature "SYSTEMD_SERVICE_INSTALL_DIR" "${placeholder "out"}/lib/systemd/system")
  ];

  patches = [
    ./001-fix-lib-dir.patch
  ];

  postPatch = ''
    substituteInPlace plugins/platform/linux/auth-helper/CMakeLists.txt --replace-fail SETUID ""
  '';

  meta = {
    description = "Cross-platform computer monitoring and classroom management";
    homepage = "https://veyon.io";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.linux;
    mainProgram = "veyon-master";
  };
})
