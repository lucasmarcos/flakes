{
  lib,
  writeShellScript,
  writeShellApplication,
  writeText,
  pacman,
  bubblewrap,
}:
let
  mirror = "http://archlinux.c3sl.ufpr.br/$repo/os/$arch";
  pacmanconf = writeText "pacman.conf" (
    lib.generators.toINI { } {
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
      # multilib = {
      #   Server = mirror;
      # };
    }
  );
  enterAsSteam = writeShellScript "enterAsSteam" ''
    ROOTFS="$(dirname "$(readlink -f "$0")")"
    ${bubblewrap}/bin/bwrap \
      --clearenv \
      --unshare-all \
      --share-net \
      --bind "$ROOTFS" / \
      --dev /dev \
      --proc /proc \
      --ro-bind /sys /sys \
      --tmpfs /tmp \
      --tmpfs /run \
      --setenv PATH /usr/bin \
      --setenv TERM xterm \
      --setenv HOME /home/steam \
      --setenv WAYLAND_DISPLAY wayland-0 \
      --setenv DISPLAY :0 \
      --setenv XDG_RUNTIME_DIR /run/user/1000 \
      --setenv LANG en_US.UTF-8 \
      --bind /tmp/.X11-unix/X0 /tmp/.X11-unix/X0 \
      --bind /run/user/1000/wayland-0 /run/user/1000/wayland-0 \
      --bind /run/user/1000/pipewire-0 /run/user/1000/pipewire-0 \
      bash
  '';
  enterAsRoot = writeShellScript "enterAsRoot" ''
    ROOTFS="$(dirname "$(readlink -f "$0")")"
    ${bubblewrap}/bin/bwrap \
      --uid 0 \
      --gid 0 \
      --clearenv \
      --unshare-all \
      --share-net \
      --bind "$ROOTFS" / \
      --dev /dev \
      --proc /proc \
      --tmpfs /tmp \
      --tmpfs /run \
      --tmpfs /var/cache \
      --setenv PATH /usr/bin \
      --setenv TERM xterm \
      --setenv HOME /root \
      bash
  '';
in
writeShellApplication {
  name = "build-archlinux-rootfs";
  text = ''
    ROOTFS="''${XDG_STATE_HOME:-$HOME/.local/state}/steam-archlinux-bwarp"
    mkdir -p "$ROOTFS/etc"
    mkdir -p "$ROOTFS/var/lib/pacman"
    cp -f "${pacmanconf}" "$ROOTFS/etc/pacman.conf"
    echo "nameserver 1.1.1.1" > "$ROOTFS/etc/resolv.conf"

    ${bubblewrap}/bin/bwrap \
      --uid 0 \
      --gid 0 \
      --clearenv \
      --unshare-all \
      --share-net \
      --clearenv \
      --proc /proc \
      --dev /dev \
      --tmpfs /tmp \
      --tmpfs /run \
      --tmpfs /var/cache \
      --bind /nix /nix \
      --bind "$ROOTFS/etc/resolv.conf" /etc/resolv.conf \
      --bind "$ROOTFS" "$ROOTFS" \
        ${pacman}/bin/pacman \
        --sysroot "$ROOTFS" \
        -Syu \
        --needed \
        --noconfirm \
          base \
          lib32-glibc \
          lib32-gcc-libs

    ${bubblewrap}/bin/bwrap \
      --uid 0 \
      --gid 0 \
      --clearenv \
      --unshare-all \
      --share-net \
      --proc /proc \
      --dev /dev \
      --tmpfs /tmp \
      --tmpfs /run \
      --tmpfs /var/cache \
      --bind "$ROOTFS" / \
      --setenv PATH /usr/bin \
        update-ca-trust

    ${bubblewrap}/bin/bwrap \
      --uid 0 \
      --gid 0 \
      --clearenv \
      --unshare-all \
      --share-net \
      --proc /proc \
      --dev /dev \
      --tmpfs /tmp \
      --tmpfs /run \
      --tmpfs /var/cache \
      --bind "$ROOTFS" / \
      --setenv PATH /usr/bin \
        dbus-uuidgen --ensure=/etc/machine-id

    echo "steam:x:$(id -u):$(id -g)::/home/steam:/usr/bin/bash" >> "$ROOTFS/etc/passwd"
    echo "steam:x:$(id -g):steam" >> "$ROOTFS/etc/group"

    mkdir -p "$ROOTFS/home/steam/.local/share/Steam/package"

    echo "en_US.UTF-8 UTF-8" > "$ROOTFS/etc/locale.gen"
    echo "LANG=en_US.UTF-8" > "$ROOTFS/etc/locale.conf"

    ${bubblewrap}/bin/bwrap \
      --uid 0 \
      --gid 0 \
      --clearenv \
      --unshare-all \
      --share-net \
      --proc /proc \
      --dev /dev \
      --tmpfs /tmp \
      --tmpfs /run \
      --tmpfs /var/cache \
      --bind "$ROOTFS" / \
      --setenv PATH /usr/bin \
        locale-gen

    cp -f "${enterAsSteam}" "$ROOTFS/enterAsSteam"
    cp -f "${enterAsRoot}" "$ROOTFS/enterAsRoot"
  '';
}
