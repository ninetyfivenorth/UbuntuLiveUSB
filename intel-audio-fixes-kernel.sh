#!/bin/bash

# Linuxium's scripts to create a custom Ubuntu ISO

source /include-chroot-variables.txt

CHROOT_KERNEL=`dpkg -l | awk '/^ii +linux-image-[0-9]/ {print $2}'`
CHROOT_KERNEL_VERSION=${CHROOT_KERNEL#linux-image-}

echo "fetching intel-audio-fixes"

# get kernel source and build intel-audio-fixes
cd /usr/src
wget https://github.com/plbossart/sound/archive/topic/v4.9-fixes.zip
unzip -q v4.9-fixes.zip
rm v4.9-fixes.zip
cd sound-topic-v4.9-fixes
cp -a ../aufs4-standalone.git/{Documentation,fs} .
cp ../aufs4-standalone.git/include/uapi/linux/aufs_type.h include/uapi/linux/
patch -p1 < ../aufs4-standalone.git/aufs4-kbuild.patch
patch -p1 < ../aufs4-standalone.git/aufs4-base.patch
patch -p1 < ../aufs4-standalone.git/aufs4-mmap.patch
patch -p1 < ../aufs4-standalone.git/aufs4-standalone.patch
sed 's/CONFIG_CPU_FREQ_GOV_SCHEDUTIL=m/CONFIG_CPU_FREQ_GOV_SCHEDUTIL=y/' /boot/config-${CHROOT_KERNEL_VERSION} > .config
scripts/kconfig/merge_config.sh .config /defconfig

# build debs
make -j `getconf _NPROCESSORS_ONLN` bindeb-pkg LOCALVERSION=-intel-audio-fixes