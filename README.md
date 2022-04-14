# ToyOS

目前开发的宿主机为MacBook Pro 2021款。由于CPU是ARM架构，但是该内核是基于X86开发的，因此使用了x86的Docker容器。同样的，该代码也适用于x86的Linux主机或能够允许x86 Linux容器的主机。

## 开发环境准备

安装必须的软件:
* Docker: 用于配置开发环境（主要是用于磁盘文件的挂载，因为MacOS访问ext4文件系统较为麻烦）
* Qemu: 用于测试内核的虚拟化程序

设置Docker默认使用amd64架构的镜像，然后下载任意Linux镜像即可。(该环境变量对于x86主机则不需要)

```sh
export DOCKER_DEFAULT_PLATFORM=linux/amd64
```

可使用本人编写好的Docker镜像：[https://hub.docker.com/r/rlyown/cdev_host](https://hub.docker.com/r/rlyown/cdev_host)。 或者直接通过编写好的脚本`build.sh`使用, 脚本的使用方法直接看输出的帮助信息即可。


这里解释一下脚本中重要命令的含义：
```sh
docker run --rm -w /home/bingo/Workdir -v ${PWD}/:/home/bingo/Workdir --privileged rlyown/cdev_host:latest make
```

* `--rm`: 容器运行完后删除
* `-w /home/bingo/Workdir`：设置容器的工作目录
* `-v .:/home/bingo/Workdir`：将宿主机的当前目录映射到工作目录
* `--privileged`：启用特权，因为编译磁盘的过程需要挂载，因此该选项是必须的

