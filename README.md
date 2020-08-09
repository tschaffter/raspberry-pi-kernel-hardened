# Hardened Kernel Builder for Raspberry Pi

[![GitHub Stars](https://img.shields.io/github/stars/tschaffter/raspberry-pi-kernel-hardened.svg?color=94398d&labelColor=555555&logoColor=ffffff&style=for-the-badge&logo=github)](https://github.com/tschaffter/raspberry-pi-kernel-hardened)
[![GitHub Release](https://img.shields.io/github/release/tschaffter/raspberry-pi-kernel-hardened.svg?color=94398d&labelColor=555555&logoColor=ffffff&style=for-the-badge&logo=github)](https://github.com/tschaffter/raspberry-pi-kernel-hardened/releases)
[![Docker Stars](https://img.shields.io/docker/stars/tschaffter/raspberry-pi-kernel-hardened.svg?color=94398d&labelColor=555555&logoColor=ffffff&style=for-the-badge&label=stars&logo=docker)](https://hub.docker.com/r/tschaffter/raspberry-pi-kernel-hardened)
[![GitHub CI](https://img.shields.io/github/workflow/status/tschaffter/raspberry-pi-kernel-hardened/ci.svg?color=94398d&labelColor=555555&logoColor=ffffff&style=for-the-badge&logo=github)](https://github.com/tschaffter/raspberry-pi-kernel-hardened)
[![GitHub License](https://img.shields.io/github/license/tschaffter/raspberry-pi-kernel-hardened.svg?color=94398d&labelColor=555555&logoColor=ffffff&style=for-the-badge&logo=github)](https://github.com/tschaffter/raspberry-pi-kernel-hardened)

Cross-compile the [Linux kernel for Raspberry Pi][raspberrypi_kernel_build] with
enhanced security support in a single command.

## Features

- Dockerized tool to cross-compile an hardened kernel for the Pi with a single command
- Hardened kernel features
  - Add Audit support
  - Add SELinux support

## Usage

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

## Build the hardened kernel

### Identify the kernel version to build

Go to the GitHub repository of the [Linux kernel of Raspberry Pi][gh_raspberrypi/linux]
and identify the name of the branch or tag that you want to build.

Examples:

- The branch `rpi-5.4.y`
- The tag `raspberrypi-kernel_1.20200527-1`

### Identify the default configuration to use

Go to the page [Kernel building][raspberrypi_kernel_build] of the Raspberry Pi
website to identify the default build configuration to use for the target Pi.

Examples:

- `bcmrpi_defconfig` for Raspberry Pi 1, Pi Zero, Pi Zero W, and Compute Module
- `bcm2709_defconfig` for Raspberry Pi 2, Pi 3, Pi 3+, and Compute Module 3
- `bcm2711_defconfig` for Raspberry Pi 4

Check the above documentation to make sure that these examples are up-to-date.

### Cross-compile the kernel

The command below builds the branch `rpi-5.4.y` for the Raspberry Pi 4
(`bcm2711_defconfig`). Because this branch is in progress, we include today's
date to the value of `--kernel-localversion` (`5.4.y-20200804-hardened`). You
can set the value of `--kernel-localversion` to anything you want.

Once installed, the full kernel name will be:

```console
$ uname -a
Linux raspberrypi 5.4.51-5.4.y-20200804-hardened+ #1 SMP Sun Jun 14 15:06:51 UTC 2020 armv7l GNU/Linux
```

This command builds kernel:

```console
$ docker run \
    --rm \
    -v $PWD/output:/output \
    tschaffter/raspberry-pi-kernel-hardened \
        --kernel-branch rpi-5.4.y \
        --kernel-defconfig bcm2711_defconfig \
        --kernel-localversion 5.4.y-$(date '+%Y%m%d')-hardened
Cloning into '/home/builder/tools'...
Installing cross compiler toolchain
Checking out files: 100% (19059/19059), done.
Getting kernel source code
Cloning into '/home/builder/linux'...
...

Moving .deb packages to /output
SUCCESS The kernel has been successfully packaged.

INSTALL
sudo dpkg -i linux-*-5.4.y-20200804-hardened*.deb
sudo sh -c "echo 'kernel=vmlinuz-5.4.51-5.4.y-20200804-hardened+' >> /boot/config.txt"
sudo reboot

ENABLE SELinux
sudo apt-get install selinux-basics selinux-policy-default auditd
sudo sh -c "sed -i '$ s/$/ selinux=1 security=selinux/' /boot/cmdline.txt"
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
that is all the CPU cores of the host. Use [Docker runtime options][docker_runtime_options]
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
        --kernel-branch rpi-5.4.y \
        --kernel-defconfig bcm2711_defconfig \
        --kernel-localversion 5.4.y-$(date '+%Y%m%d')-hardened
```

## Contributing change

Please read the [`CONTRIBUTING.md`](CONTRIBUTING.md) for details on how to
contribute to this project.

<!-- Definitions -->

[raspberrypi_kernel_build]: https://www.raspberrypi.org/documentation/linux/kernel/building.md
[gh_raspberrypi/linux]: https://github.com/raspberrypi/linux
[docker_runtime_options]: https://docs.docker.com/config/containers/resource_constraints/#cpu
