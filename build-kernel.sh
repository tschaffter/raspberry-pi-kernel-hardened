#!/bin/bash
#
#   @tschaffter
#
#   Cross-compiles the Raspberry Pi kernel with SELinux support and other
#   hardening features enabled.
#
#   Example:
#
#   ./build-kernel.sh \
#       --kernel-branch rpi-4.19.y \
#       --kernel-defconfig bcm2711_defconfig \
#       --kernel-localversion 4.19.y-20200607-hardened
#
#   Notes:
#
#   - Identify kernel branch or tag from https://github.com/raspberrypi/linux
#   - Identify --kernel-defconfig value from https://www.raspberrypi.org/documentation/linux/kernel/building.md
#   - The value of --kernel-localversion will be returned by `uname -a`
#
# ARG_OPTIONAL_SINGLE([kernel-branch],[],[Kernel branch to build],[''])
# ARG_OPTIONAL_SINGLE([kernel-defconfig],[],[Default kernel config to use],[''])
# ARG_OPTIONAL_SINGLE([kernel-localversion],[],[Kernel local version],[''])
# ARG_HELP([The general script's help msg])
# ARGBASH_GO()
# needed because of Argbash --> m4_ignore([
### START OF CODE GENERATED BY Argbash v2.8.1 one line above ###
# Argbash is a bash code generator used to get arguments parsing right.
# Argbash is FREE SOFTWARE, see https://argbash.io for more info
# Generated online by https://argbash.io/generate


die()
{
	local _ret=$2
	test -n "$_ret" || _ret=1
	test "$_PRINT_HELP" = yes && print_help >&2
	echo "$1" >&2
	exit ${_ret}
}


begins_with_short_option()
{
	local first_option all_short_options='h'
	first_option="${1:0:1}"
	test "$all_short_options" = "${all_short_options/$first_option/}" && return 1 || return 0
}

# THE DEFAULTS INITIALIZATION - OPTIONALS
_arg_kernel_branch=""
_arg_kernel_defconfig=""
_arg_kernel_localversion=""


print_help()
{
	printf '%s\n' "Cross-compiling hardened kernels for Raspberry Pi"
	printf 'Usage: %s [--kernel-branch <arg>] [--kernel-defconfig <arg>] [--kernel-localversion <arg>] [-h|--help]\n' "$0"
	printf '\t%s\n' "--kernel-branch: Kernel branch to build (default: '')"
    printf '\t%s\n' "--kernel-defconfig: Default kernel config to use (default: '')"
    printf '\t%s\n' "--kernel-localversion: Kernel local version (default: '')"
	printf '\t%s\n' "-h, --help: Prints help"
}


parse_commandline()
{
	while test $# -gt 0
	do
		_key="$1"
		case "$_key" in
			--kernel-branch)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_kernel_branch="$2"
				shift
				;;
			--kernel-branch=*)
				_arg_kernel_branch="${_key##--kernel-branch=}"
				;;
            --kernel-defconfig)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_kernel_defconfig="$2"
				shift
				;;
			--kernel-defconfig=*)
				_arg_kernel_defconfig="${_key##--kernel-defconfig=}"
				;;
            --kernel-localversion)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_kernel_localversion="$2"
				shift
				;;
			--kernel-localversion=*)
				_arg_kernel_localversion="${_key##--kernel-localversion=}"
				;;
			-h|--help)
				print_help
				exit 0
				;;
			-h*)
				print_help
				exit 0
				;;
			*)
				_PRINT_HELP=yes die "FATAL ERROR: Got an unexpected argument '$1'" 1
				;;
		esac
		shift
	done
}

parse_commandline "$@"

# OTHER STUFF GENERATED BY Argbash

### END OF CODE GENERATED BY Argbash (sortof) ### ])
# [ <-- needed because of Argbash

# The argument --kernel-branch must be specified.
if [ -z "$_arg_kernel_branch" ]; then
    echo "The argument --kernel-branch <arg> is missing."
    exit 1
fi

# The argument --kernel-defconfig must be specified.
if [ -z "$_arg_kernel_defconfig" ]; then
    echo "The argument --kernel-defconfig <arg> is missing."
    exit 1
fi

# The argument --kernel-localversion must be specified.
if [ -z "$_arg_kernel_localversion" ]; then
    echo "The argument --kernel-localversion <arg> is missing."
    exit 1
fi

_workdir=$(pwd)
_tools_dir=$_workdir/tools
_kernel_src_dir=$_workdir/linux
_ccprefix="$_tools_dir/arm-bcm2708/arm-linux-gnueabihf/bin/arm-linux-gnueabihf-"
_output_dir=/output


# Check that the output directory exists and is writable
test -d $_output_dir || die "Output directory $_output_dir does not exist" 1
test -w $_output_dir || die "Output directory $_output_dir is not writable" 1


# Install toolchain
if [ -d $_tools_dir ]; then
    echo "Using exsiting cross compiler toolchain $_tools_dir"
else
    echo "Installing cross compiler toolchain"
    git clone https://github.com/raspberrypi/tools $_tools_dir \
        || die "ERROR: Unable to clone the cross compiler toolchain" 1
fi


# Get the kernel source code
if [ -d $_kernel_src_dir ]; then
    echo "Using existing kernel source dir $_kernel_src_dir"
else
    echo "Getting kernel source code"
    git clone \
        --branch $_arg_kernel_branch \
        --depth=1 \
        https://github.com/raspberrypi/linux \
        $_kernel_src_dir \
        || die "Unable to clone kernel source code" 1
fi


cd $_kernel_src_dir

_kernel_version=$(make kernelversion)

echo "Kernel version is $_kernel_version"
echo "Kernel local version is $_arg_kernel_localversion"

echo "Cleaning up the directory"
make mrproper

echo "Creating initial .config"
make ARCH=arm CROSS_COMPILE=$_ccprefix $_arg_kernel_defconfig \
    || die "Unable to create initial .config" 1

echo "Setting kernel local version"
./scripts/config --set-str  CONFIG_LOCALVERSION "-$_arg_kernel_localversion"

echo "Enabling Audit"
./scripts/config --enable CONFIG_AUDIT
./scripts/config --enable CONFIG_AUDIT_LOGINUID_IMMUTABLE

echo "Enabling Security"
./scripts/config --enable CONFIG_SECURITY
./scripts/config --enable CONFIG_SECURITY_NETWORK

echo "Enabling SELinux"
./scripts/config --enable   CONFIG_SECURITY_SELINUX
./scripts/config --enable   CONFIG_SECURITY_SELINUX_BOOTPARAM
./scripts/config --set-val  CONFIG_SECURITY_SELINUX_BOOTPARAM_VALUE 1
./scripts/config --disable  CONFIG_SECURITY_SELINUX_DISABLE
./scripts/config --enable   CONFIG_SECURITY_SELINUX_DEVELOP
./scripts/config --enable   CONFIG_SECURITY_SELINUX_AVC_STATS
./scripts/config --set-val  CONFIG_SECURITY_SELINUX_CHECKREQPROT_VALUE 1
# ./scripts/config --disable  CONFIG_SECURITY_SELINUX_POLICYDB_VERSION_MAX
./scripts/config --enable   CONFIG_DEFAULT_SECURITY_SELINUX
./scripts/config --disable  CONFIG_DEFAULT_SECURITY_DAC
./scripts/config --set-str  CONFIG_DEFAULT_SECURITY "selinux"

# Validate config changes
make ARCH=arm CROSS_COMPILE=$_ccprefix olddefconfig

# Alternatively, update config using menuconfig (interactive)
# make ARCH=arm CROSS_COMPILE=$_ccprefix menuconfig

echo "Building kernel and generating .deb packages"
DEB_HOST_ARCH=armhf make ARCH=arm CROSS_COMPILE=$_ccprefix deb-pkg -j$(($(nproc)+1)) \
    || die "Unable to build or package kernel" 1

ls -al

echo "Moving .deb packages to $_output_dir"
mv $_workdir/*.deb /output


echo "SUCCESS The kernel has been successfully packaged."
echo ""
echo "INSTALL"
echo "sudo dpkg -i linux-*-${_arg_kernel_localversion}*.deb"
echo "sudo sh -c \"echo 'kernel=vmlinuz-${_kernel_version}-${_arg_kernel_localversion}+' >> /boot/config.txt\""
echo "sudo reboot"
echo ""
echo "ENABLE SELinux"
echo "sudo apt-get install selinux-basics selinux-policy-default auditd"
echo "sudo sh -c \"echo ' selinux=1 security=selinux' >> /boot/cmdline.txt\""
echo "sudo touch /.autorelabel"
echo "sudo reboot"
echo "sestatus"

# ] <-- needed because of Argbash
