{
  lib,
  writeShellApplication,
  pacman,
  fakeroot,
  bubblewrap,
  stdenvNoCC,
  fetchurl,
  libarchive,
}:
let
  mirror = "http://archlinux.c3sl.ufpr.br/\\$repo/os/\\$arch";
  pacmanconf = lib.generators.toINI { } {
    options = {
      Architecture = "x86_64";
    };
    core = {
      Server = mirror;
    };
    extra = {
      Server = mirror;
    };
  };
  enter = writeShellApplication {
    name = "enter";
    runtimeInputs = [ bubblewrap ];
    text = ''
      ROOTFS="$(dirname "$(readlink -f "$0")")"
      bwrap \
        --clearenv \
        --unshare-all \
        --share-net \
        --bind "$ROOTFS" / \
        --dev /dev \
        --proc /proc \
        --ro-bind /sys /sys \
        --tmpfs /tmp \
        --tmpfs /run \
        --setenv PATH /bin \
        --setenv TERM xterm \
        --setenv HOME /home/lucas \
        --setenv WAYLAND_DISPLAY wayland-0 \
        --setenv DISPLAY :0 \
        --setenv XDG_RUNTIME_DIR /run/user/1000 \
        --bind /tmp/.X11-unix/X0 /tmp/.X11-unix/X0 \
        --bind /run/user/1000/wayland-0 /run/user/1000/wayland-0 \
        --bind /run/user/1000/pipewire-0 /run/user/1000/pipewire-0 \
        bash
    '';
  };
  archlinux-keys = stdenvNoCC.mkDerivation {
    pname = "archlinux-keyring";
    version = "20260420-1";
    nativeBuildInputs = [ libarchive ];
    unpackCmd = "bsdtar -x -f $src";
    src = fetchurl {
      url = "https://archlinux.c3sl.ufpr.br/core/os/x86_64/archlinux-keyring-20260420-1-any.pkg.tar.zst";
      hash = "sha256-auVaB4uPXX88nGYczQUr0RS1L6A7jHyRpFP/KqqhhxY=";
    };
    postInstall = ''
      mkdir -p $out
      cp share/pacman/keyrings/* $out/
    '';
  };
in
writeShellApplication {
  name = "build-archlinux-rootfs";
  runtimeInputs = [
    pacman
    fakeroot
  ];
  text = ''
    ROOTFS="''${XDG_STATE_HOME:-$HOME/.local/state}/archlinux"
    mkdir -p "$ROOTFS/etc"
    mkdir -p "$ROOTFS/var/lib/pacman"
    echo "${pacmanconf}" > "$ROOTFS/etc/pacman.conf"
    echo "nameserver 1.1.1.1" > "$ROOTFS/etc/resolv.conf"
    fakeroot pacman-key --populate-from "${archlinux-keys}" --config "$ROOTFS/etc/pacman.conf" --gpgdir "$ROOTFS/etc/pacman.d/gnupg" --init
    fakeroot pacman-key --populate-from "${archlinux-keys}" --config "$ROOTFS/etc/pacman.conf" --gpgdir "$ROOTFS/etc/pacman.d/gnupg" --populate archlinux
    fakeroot pacman --sysroot "$ROOTFS" -Syu --needed base fakeroot
    cp -f "${enter}/bin/enter" "$ROOTFS/"
  '';
}
