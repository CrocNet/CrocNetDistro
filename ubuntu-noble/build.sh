#!/bin/bash

set -e

# ROOTFS output directory
if [ ! -d "$ROOTFS" ]; then
  echo "ROOTFS (${ROOTFS}) not found"
  exit 1
fi

#Copy of distro configure directory in docker container
DISTRO_DIR="/distro"

source /distro/ENV

rm -rf $ROOTFS/*
echo "debootstrap stage 1 $DISTRO $ROOTFS $DISTRO_URL"
update-binfmts --enable
debootstrap --exclude vim --arch=$ARCH --foreign $DISTRO $ROOTFS $DISTRO_URL

echo "Copy $QEMU"
cp -rf /usr/bin/$QEMU $ROOTFS/usr/bin/
echo "Copy bootstrap.sh"
cp $DISTRO_DIR/bootstrap.sh $ROOTFS/.


# Fix poor qemu speed https://unix.stackexchange.com/questions/759188/some-binaries-are-extremely-slow-with-qemu-user-static-inside-docker
rm $ROOTFS/proc
mkdir -p $ROOTFS/proc
mount -v -t proc /proc $ROOTFS/proc

# chroot into the rootfs we just created
echo "==========  CHROOT $ROOTFS =========="
chroot $ROOTFS /debootstrap/debootstrap --second-stage
mount -v -t proc /proc $ROOTFS/proc  # we have to remount here
chroot $ROOTFS /bin/bash /bootstrap.sh
echo "========== EXIT CHROOT =========="

umount $ROOTFS/proc
rm $ROOTFS/bootstrap.sh
cp -rf $DISTRO_DIR/etc $ROOTFS/.

