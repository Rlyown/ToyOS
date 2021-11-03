#!/bin/bash
set -e

OPTION=$1
DISK=$2

case $OPTION in
    "create")
        # 创建分区表
        parted -s $DISK mklabel msdos
        parted -s $DISK mkpart primary 1M 100%
        parted -s $DISK set 1 boot on

        # 格式化分区
        LOOP_DEV=`losetup -f`
        losetup -P $LOOP_DEV $DISK
        mkfs.ext4 "$LOOP_DEV"p1

        parted -s $DISK print

        mkdir ISO

        mount "$LOOP_DEV"p1 ISO 
        mkdir -p ISO/boot/grub

        grub-install --boot-directory=ISO/boot --target=i386-pc ${LOOP_DEV}

        umount ISO
        rmdir ISO

        losetup -d $LOOP_DEV
        ;;
    "load")
        KERNEL=$3
        GRUB_CFG=$4

        LOOP_DEV=`losetup -f`
        losetup -P $LOOP_DEV $DISK
        
        mkdir ISO
        mount "$LOOP_DEV"p1 ISO 
        cp $KERNEL ISO/boot
        cp $GRUB_CFG ISO/boot/grub

        umount ISO
        rmdir ISO

        losetup -d $LOOP_DEV
        ;;
esac
