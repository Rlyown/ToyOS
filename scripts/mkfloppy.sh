#!/bin/bash
set -e
set -x

OPTION=$1
DISK=$2

function make_subpart() {
	LOOPDEV=$1

	if [[ -e "$LOOPDEV"p1 ]]; then
		echo "Device "$LOOPDEV"p1 detected, skip mknod"
		return 0
	fi

	PARTITIONS=$(lsblk --raw --output "MAJ:MIN" --noheadings ${LOOPDEV} | tail -n +2)
	COUNTER=1
	for i in $PARTITIONS; do
		MAJ=$(echo $i | cut -d: -f1)
		MIN=$(echo $i | cut -d: -f2)
		if [ ! -e "${LOOPDEV}p${COUNTER}" ]; then mknod ${LOOPDEV}p${COUNTER} b $MAJ $MIN; fi
		COUNTER=$((COUNTER + 1))
	done
}

function remove_subpart() {
	LOOPDEV=$1
	if [[ -e "$LOOPDEV"p1 ]]; then
		echo "Device "$LOOPDEV"p1 still exist, manually remove it"
		rm -f "$LOOPDEV"p*
	fi
}

case $OPTION in
"create")
	# create raw disk file
	dd if=/dev/zero of=$DISK bs=512 count=$((32 * 1024 * 1024 / 512))

	# create parition table
	parted -s $DISK mklabel msdos
	parted -s $DISK mkpart primary 2048s 100%
	parted -s $DISK set 1 boot on

	# format disk
	LOOP_DEV=$(losetup --find --show --partscan ${DISK})
	make_subpart $LOOP_DEV
	mkfs.ext4 -q "$LOOP_DEV"p1

	mkdir ISO
	mount "$LOOP_DEV"p1 ISO

	mkdir -p ISO/boot/grub

	grub-install --boot-directory=ISO/boot --force --allow-floppy --target=i386-pc ${LOOP_DEV}

	umount ISO
	rmdir ISO

	losetup -d $LOOP_DEV
	remove_subpart $LOOP_DEV
	;;
"load")
	KERNEL=$3
	GRUB_CFG=$4

	LOOP_DEV=$(losetup --find --show --partscan ${DISK})
	make_subpart $LOOP_DEV

	mkdir ISO
	mount "$LOOP_DEV"p1 ISO
	cp $KERNEL ISO/boot
	cp $GRUB_CFG ISO/boot/grub

	umount ISO
	rmdir ISO

	losetup -d $LOOP_DEV
	remove_subpart $LOOP_DEV
	;;
esac
