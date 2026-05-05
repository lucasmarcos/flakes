{
  lib,
  writeShellApplication,
  pacman,
  fakeroot,
  bubblewrap,
}:
let
  mirror = "http://archlinux.c3sl.ufpr.br/\\$repo/os/\\$arch";
  pacmanconf = lib.generators.toINI { } {
    options = {
      Architecture = "x86_64";
      SigLevel = "Never";
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
    fakeroot pacman --sysroot "$ROOTFS" -Syu --needed base fakeroot
    cp -f "${enter}/bin/enter" "$ROOTFS/"
  '';
}
