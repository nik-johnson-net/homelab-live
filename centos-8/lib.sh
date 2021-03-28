INSTALL_PACKAGES=(
    dracut-live
    dracut-network
    dracut-squash
    util-linux
    wget
)

DRACUT_MODULES=(
    base
    dm
    dmsquash-live
    livenet
    network
    shutdown
)

KERNEL_DRIVERS=()

function init_image() {
    dnf install -y -q --nodocs --releasever=8 --installroot="$PWD" --setopt=install_weak_deps=False "@Core" "kernel" "dnf"
    dnf install -y -q --nodocs --installroot="$PWD" "epel-release"
}

function install() {
    dnf install -y -q --nodocs --installroot="$PWD" "$@"
}

function post_install() {
    chroot "$PWD" /bin/sh -c 'echo "root" | passwd --force --stdin root'
    chroot "$PWD" mknod /dev/console u 5 1 || true
    chroot "$PWD" mkdir -p /etc/systemd/system/getty.target.wants
    # chroot "$PWD" ln -sf /usr/lib/systemd/system/serial-getty@.service /etc/systemd/system/getty.target.wants/serial-getty@ttyS1.service
    # chroot "$PWD" ln -sf /usr/lib/systemd/system/console-getty.service /etc/systemd/system/getty.target.wants/console-getty.service
}

function clean() {
    rm -rf var/cache/dnf/*
}