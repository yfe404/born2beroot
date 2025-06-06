#!/bin/bash
# SPDX-License-Identifier: MIT

set -e # Exit on error

DEVICE=$1
[ -z "${DEVICE}" ] && echo "Usage: $0 /dev/sdX" && exit 1

udevadm info -n ${DEVICE} -q property
echo "Selected device is ${DEVICE}"
read -p "[Press enter to continue or CTRL+C to stop]"

echo "Unmounting ${DEVICE}"
umount ${DEVICE}* || true

echo "Setting partition table to MBR (BIOS)"
dd if=/dev/zero of=${DEVICE} bs=1M count=1

parted ${DEVICE} --script mklabel msdos
parted ${DEVICE} --script mkpart primary 1MiB 512MiB
parted ${DEVICE} --script set 1 boot on
parted ${DEVICE} --script mkpart primary 512MiB 100%

echo "Formatting partitions"
mkfs.vfat ${DEVICE}p1
mkfs.ext4 -FL LINUX ${DEVICE}p2

echo "Mounting OS partition"
ROOTFS="/mnt/installing-rootfs"
mkdir -p ${ROOTFS}
mount ${DEVICE}p2 ${ROOTFS}

echo "Debootstrap system"
debootstrap --variant=minbase --arch amd64 buster ${ROOTFS} http://deb.debian.org/debian/

echo "Mounting boot partition"
mkdir -p ${ROOTFS}/boot
mount ${DEVICE}p1 ${ROOTFS}/boot

echo "Preparing chroot environment"
mount --bind /dev ${ROOTFS}/dev
mount -t devpts devpts ${ROOTFS}/dev/pts
mount -t proc proc ${ROOTFS}/proc
mount -t sysfs sysfs ${ROOTFS}/sys
mount -t tmpfs tmpfs ${ROOTFS}/tmp

echo "Entering chroot, installing Linux kernel and Limine"
cat << EOF | chroot ${ROOTFS}
  set -e
  export HOME=/root
  export DEBIAN_FRONTEND=noninteractive
  export PATH=/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin

  apt-get update
  apt-get install -y linux-image-amd64 linux-headers-amd64 git make curl autoconf gcc nasm
  git clone https://github.com/limine-bootloader/limine.git
  cd limine
  ./bootstrap
  ./configue
  make
  make install

  ROOT_UUID=\$(blkid -s UUID -o value ${DEVICE}p2)

  echo "Creating Limine configuration file"
  cat << LEOF > /boot/limine.cfg
TIMEOUT=3
:Linux
PROTOCOL=linux
KERNEL_PATH=/vmlinuz
INITRD_PATH=/initrd.img
CMDLINE=root=UUID=\$ROOT_UUID quiet
LEOF

  echo "Installing Limine"
  limine-install ${DEVICE}
EOF

echo "Unmounting filesystems"
umount ${ROOTFS}/dev/pts
umount ${ROOTFS}/dev
umount ${ROOTFS}/proc
umount ${ROOTFS}/sys
umount ${ROOTFS}/tmp
umount ${ROOTFS}/boot
umount ${ROOTFS}

echo "Done! Reboot to test."
