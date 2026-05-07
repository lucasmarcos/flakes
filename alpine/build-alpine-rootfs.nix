{
  writeShellApplication,
  bubblewrap,
  apk-tools,
  alpine-keys,
}:
let
  enter = writeShellApplication {
    name = "enter";
    text = ''
      ${bubblewrap}/bin/bwrap \
        --clearenv \
        --unshare-all \
        --share-net \
        --bind "$PWD/rootfs" / \
        --dev /dev \
        --proc /proc \
        --tmpfs /tmp \
        --tmpfs /run \
        --setenv HOME "$HOME" \
        --setenv PATH /usr/bin \
        --setenv WAYLAND_DISPLAY "$WAYLAND_DISPLAY" \
        --setenv XDG_RUNTIME_DIR "/run/user/$(id -u)" \
        --setenv TERM xterm \
        --bind "/run/user/$(id -u)/$WAYLAND_DISPLAY" "/run/user/$(id -u)/$WAYLAND_DISPLAY" \
         /bin/sh
    '';
  };
in
writeShellApplication {
  name = "build-alpine-rootfs";
  text = ''
    ROOTFS="$PWD/rootfs"

    mkdir -p "$ROOTFS/usr/bin"
    mkdir -p "$ROOTFS/usr/lib/apk/db"
    mkdir -p "$ROOTFS/etc/apk"

    bsdtar \
      -x \
      -C "$ROOTFS" \
      -f "${alpine-keys}" \
      etc
     
    ln -s -f "usr/bin" "$ROOTFS/bin"
    ln -s -f "usr/sbin" "$ROOTFS/sbin"
    # ln -s -f "bin" "$ROOTFS/usr/sbin"
    ln -s -f "usr/lib" "$ROOTFS/lib"

    touch "$ROOTFS/etc/apk/world"
    echo "nameserver 1.1.1.1" > "$ROOTFS/etc/resolv.conf"
    echo "http://dl-cdn.alpinelinux.org/edge/main" > "$ROOTFS/etc/apk/repositories"
    echo "http://dl-cdn.alpinelinux.org/edge/community" >> "$ROOTFS/etc/apk/repositories"

    ${apk-tools}/bin/apk \
      --root "$ROOTFS" \
      add \
      alpine-base

    cp -f ${enter}/bin/enter "$ROOTFS/enter"
  '';
}
