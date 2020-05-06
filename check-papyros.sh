#!/bin/bash
#export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
#set -x

if [[ $EUID -ne 0 ]]; then
	echo "must run as root"
	exit 1
fi

#renice 19 $$ > /dev/null

export PATH=$PATH:/usr/local/bin

export MD_VOL=/dev/shm/xfstests

export FSTYP=papyros

export TEST_DEV=/dev/loop100
export TEST_SPARE_DEV=/dev/loop101
export TEST_DIR=/mnt/xfstests/test_dir
export TEST_MD_DIR=$MD_VOL$TEST_DEV

#SCRATCH_DEV needs to be CMR so dm-thin can be created
#May  5 06:25:22 corfu kernel: [13013.664214] device-mapper: table: 253:0: start=10240 not aligned to h/w zone size 524288 of sde
#May  5 06:25:22 corfu kernel: [13013.664215] device-mapper: core: Cannot calculate initial queue limits
#May  5 06:25:22 corfu kernel: [13013.664217] device-mapper: ioctl: unable to set up device queue for new table.
export SCRATCH_DEV=/dev/loop102
export SCRATCH_SPARE_DEV=/dev/loop103
export SCRATCH_MNT=/mnt/xfstests/scratch_dir
export SCRATCH_MD_DIR=$MD_VOL$SCRATCH_DEV

export PAPYROS_TEMP_MNT=/mnt/tmp

export HERACLES_PATH=/home/hselin/share/heracles/src

export PAPYROS_TEST_FS_MOUNT_OPTIONS="-o kernelcache,0readbuffer"

export RECREATE_TEST_DEV=true

export LIB_FUSE_PATH=/home/hselin/share/libfuse/build/lib/

umount $TEST_DIR
umount $SCRATCH_MNT
umount $PAPYROS_TEMP_MNT

mkdir -p $TEST_DIR $SCRATCH_MNT $MD_VOL$TEST_DEV $MD_VOL$SCRATCH_DEV $PAPYROS_TEMP_MNT

source ./common/papyros

LD_LIBRARY_PATH=$LIB_FUSE_PATH:$LD_LIBRARY_PATH _mkfs_papyros $TEST_DEV $TEST_SPARE_DEV $TEST_MD_DIR
LD_LIBRARY_PATH=$LIB_FUSE_PATH:$LD_LIBRARY_PATH _mkfs_papyros $SCRATCH_DEV $SCRATCH_SPARE_DEV $SCRATCH_MD_DIR

if [ $# -eq 0 ]; then
    LD_LIBRARY_PATH=$LIB_FUSE_PATH:$LD_LIBRARY_PATH ./check -b -g quick
else
    LD_LIBRARY_PATH=$LIB_FUSE_PATH:$LD_LIBRARY_PATH ./check "$@"
fi
