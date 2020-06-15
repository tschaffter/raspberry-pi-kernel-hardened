# Hardened Kernel Builder for RPi

[![Docker Image](https://github.com/tschaffter/raspberry-pi-kernel-hardened/workflows/Publish%20Docker%20Image/badge.svg)](https://hub.docker.com/repository/docker/tschaffter/raspberry-pi-kernel-hardened)

## Overview

Cross-compile the [Linux kernel for Raspberry Pi](https://www.raspberrypi.org/documentation/linux/kernel/building.md)
with enhanced security using a single command.

## Features

- Dockerized tool to cross-compile the kernel with a single command
- Hardened kernel features
  - Enable Audit
  - Enable SELinux

## Builder options

Run the folllowing command to see the options of the builder:

```console
$ docker run --rm tschaffter/raspberry-pi-kernel-hardened
Cross-compiling hardened kernels for Raspberry Pi
Usage: build-kernel.sh [--kernel-branch <arg>] [--kernel-defconfig <arg>] [--kernel-localversion <arg>] [-h|--help]
    --kernel-branch: Kernel branch to build (default: '')
    --kernel-defconfig: Default kernel config to use (default: '')
    --kernel-localversion: Kernel local version (default: '')
    -h, --help: Prints help
```

## Build the hardered kernel

### Identify the kernel version to build

Go to the GitHub repository of the [Linux kernel of Raspberry Pi](https://github.com/raspberrypi/linux)
and identify the name of the branch or tag that you want to build.

Examples:

- The branch `rpi-4.19.y`
- The tag `raspberrypi-kernel_1.20200527-1`

### Identify the default configuration to use

Go to the page [Kernel building](https://www.raspberrypi.org/documentation/linux/kernel/building.md)
of the Raspberry Pi website to identify the default build configuration to use
for the target Pi.

Examples:

- `bcmrpi_defconfig` for Raspberry Pi 1, Pi Zero, Pi Zero W, and Compute Module
- `bcm2709_defconfig` for Raspberry Pi 2, Pi 3, Pi 3+, and Compute Module 3
- `bcm2711_defconfig` for Raspberry Pi 4

Check the above documentation to make sure that these examples are up-to-date.

### Cross-compile the kernel

The command below builds the branch `rpi-4.19.y` for the Raspberry Pi 4
(`bcm2711_defconfig`). Because this branch is in progress, we include today's
date to the value of `--kernel-localversion` (`4.19.y-20200614-hardened`). You
can set the value of `--kernel-localversion` to anything you want.

Once installed, the full kernel name will be:

```console
$ uname -a
Linux raspberrypi 4.19.127-4.19.y-20200614-hardened+ #1 SMP Sun Jun 14 15:06:51 UTC 2020 armv7l GNU/Linux
```

This command builds kernel:

```console
$ docker run \
    --rm \
    -v $PWD/output:/output \
    tschaffter/raspberry-pi-kernel-hardened \
        --kernel-branch rpi-4.19.y \
        --kernel-defconfig bcm2711_defconfig \
        --kernel-localversion 4.19.y-20200614-hardened
Cloning into '/home/builder/tools'...
Installing cross compiler toolchain
Checking out files: 100% (19059/19059), done.
Getting kernel source code
Cloning into '/home/builder/linux'...
...

Moving .deb packages to /output
SUCCESS The kernel has been successfully packaged.

INSTALL
sudo dpkg -i linux-*-4.19.y-20200614-hardened*.deb
sudo sh -c "echo 'kernel=vmlinuz-4.19.127-4.19.y-20200614-hardened+' >> /boot/config.txt"
sudo reboot

ENABLE SELinux
sudo apt-get install selinux-basics selinux-policy-default auditd
sudo sh -c "echo ' selinux=1 security=selinux' >> /boot/cmdline.txt"
sudo touch /.autorelabel
sudo reboot
sestatus
```

## Install the kernel

Copy the Debian packages `$PWD/output/*.deb` to the target Raspbery Pi, for
example using `scp`, then follow the instructions given at the end of the build
command.

## Customize your build

- The builder uses all the CPU cores available to the Docker container. By default,
that is all the CPU cores of the host. Use
[Docker runtime options](https://docs.docker.com/config/containers/resource_constraints/#cpu)
to limit the usage of CPU cores by the builder.

- The builder clones two GitHub repositories, the cross-compiler toolchain and
the source code of the kernel, unless their target directories already exist
(`/home/builder/tools` and `/home/builder/linux`). When running the dockerized
builder, you can mount volumes that points to these two directories to specify
a different toolchain and kernel source code.

```console
$ git clone <toolchain-repo> tools
$ git clone <kernel-repo> linux
$ docker run \
    --rm \
    -v $PWD/output:/output \
    -v $PWD/tools:/home/builder/tools \
    -v $PWD/linux:/home/builder/linux \
    tschaffter/raspberry-pi-kernel-hardened \
        --kernel-branch rpi-4.19.y \
        --kernel-defconfig bcm2711_defconfig \
        --kernel-localversion 4.19.y-20200614-hardened
```

## Contributing change

Please read the [`CONTRIBUTING.md`](CONTRIBUTING.md) for details on how to
contribute to this project.
