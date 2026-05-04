{ lib, writeShellApplication, pacman, fakeroot, bubblewrap }:
let
  mirror = "http://archlinux.c3sl.ufpr.br/\\$repo/os/\\$arch";
  pacmanconf = lib.generators.toINI {} {
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
in
writeShellApplication {
  name = "build-archlinux-rootfs";
  runtimeInputs = [ pacman fakeroot ];
  text = ''
    mkdir -pv "$HOME/.local/share/archlinux/etc"
    mkdir -pv "$HOME/.local/share/archlinux/var/lib/pacman"
    echo "${pacmanconf}" > "$HOME/.local/share/archlinux/etc/pacman.conf"
    echo "nameserver 1.1.1.1" > "$HOME/.local/share/archlinux/etc/resolv.conf"
    fakeroot pacman --sysroot "$HOME/.local/share/archlinux" -Syu --needed base fakeroot
    echo "
      #!/usr/bin/env bash

      ${bubblewrap}/bin/bwrap \
        --clearenv \
        --unshare-all \
        --share-net \
        --bind ""$HOME/.local/share/archlinux"" / \
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
    " > "$HOME/.local/share/archlinux/enter"

    chmod +x "$HOME/.local/share/archlinux/enter"
  '';
}
