#!/bin/bash

set -e

function help() {
	echo -e "Usage: $0 <target>"
	echo -e "\tfloppy: Create raw disk image"
	echo -e "\tbootimg: Load kernel and grub.cfg to disk image"
	echo -e "\trun: Run kernel by qemu"
	echo -e "\tkernel: Build kernel only"
	echo -e "\tclean: Clean resulting file"
}

CURRENT=$(dirname $(readlink -f "$0"))

# 设置默认的容器架构为amd64
export DOCKER_DEFAULT_PLATFORM=linux/amd64

# 检查Docker镜像是否存在
docker inspect --type=image rlyown/cdev_host &>/dev/null
if [[ ! $? == 0 ]]; then
	echo -e "Docker image rlyown/cdev_host not found, pull it"
	docker pull rlyown/cdev_host:latest
fi

case "$1" in
"floppy" | "bootimg" | "kernel" | "clean")
	docker run --rm -w /home/bingo/Workdir -v $CURRENT/:/home/bingo/Workdir --privileged rlyown/cdev_host:latest make $1
	;;
"run")
	if [[ ! "${PWD}" == "${CURRENT}" ]]; then
		cd $CURRENT
	fi
	make run
	;;
*)
	help
	;;
esac
