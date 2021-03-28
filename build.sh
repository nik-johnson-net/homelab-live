#!/bin/bash

set -e

function fail() {
    echo "$@" >&2
    exit 1
}

function apply_overlay() {
    cp -dR "$OVERLAY/"* "$PWD"
}

function create_rootfs() {
    rm -f "$BUILD_ROOT/squashfs.img"
    mksquashfs "$PWD" "$BUILD_ROOT/squashfs.img" -comp xz -no-progress -noappend
    tar -C "$BUILD_ROOT" -cf "$BUILD_ROOT/squashfs.tgz" "squashfs.img"
    chown $SUDO_USER:$SUDO_USER "$BUILD_ROOT/squashfs.tgz"
}

function create_vmlinuz() {
    rm "$BUILD_ROOT/vmlinuz"
    cp "boot/vmlinuz-${kernel_version}" "$BUILD_ROOT/vmlinuz"
    chown $SUDO_USER:$SUDO_USER "$BUILD_ROOT/vmlinuz"
}

function create_initramfs() {
    dracut_modules=""
    for module in "${DRACUT_MODULES[@]}"; do
        dracut_modules="$dracut_modules --add $module"
    done

    chroot "$PWD" dracut -N $dracut_modules "/initramfs.img" "$kernel_version"
    mv "$BUILD_PATH/initramfs.img" "$BUILD_ROOT/initramfs.img"
    chmod 644 "$BUILD_ROOT/initramfs.img"
    chown $SUDO_USER:$SUDO_USER "$BUILD_ROOT/initramfs.img"
}

[[ -f "$1/lib.sh" ]] || fail "$1 not an available image $1"
source "$1/lib.sh"

BUILD_PATH="$PWD/build/$1"
OVERLAY="$PWD/$1/overlay"

mkdir -p build
cd build
BUILD_ROOT="$PWD"

rm -rf "$BUILD_PATH"
mkdir -p "$BUILD_PATH"
cd "$BUILD_PATH"

echo "Building system image..."
init_image
install "${INSTALL_PACKAGES[@]}"
apply_overlay
post_install
clean

kernel_version=$(ls boot | grep vmlinuz | grep -v rescue | cut -d'-' -f2- | sort -r)
echo "Building bootable environment with kernel $kernel_version"

create_rootfs
create_vmlinuz
create_initramfs