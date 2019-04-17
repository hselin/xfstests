#!/bin/bash

export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

#set -x

if [[ $EUID -ne 0 ]]; then
	echo "must run as root"
	exit 1
fi

#renice 19 $$ > /dev/null

export PATH=$PATH:/usr/local/bin

export MD_VOL=/md-vol

export FSTYP=papyros
export TEST_DEV=/dev/loop0
export TEST_SPARE_DEV=/dev/loop1
export TEST_DIR=/mnt/xfstests/test_dir
export TEST_MD_DIR=$MD_VOL$TEST_DEV

export SCRATCH_DEV=/dev/loop2
export SCRATCH_SPARE_DEV=/dev/loop3
export SCRATCH_MNT=/mnt/xfstests/scratch_dir
export SCRATCH_MD_DIR=$MD_VOL$SCRATCH_DEV

export HERACLES_PATH=/home/hselin/share/evimero/heracles/src


export RECREATE_TEST_DEV=true


umount $TEST_DIR
umount $SCRATCH_MNT

mkdir -p $TEST_DIR $SCRATCH_MNT $MD_VOL$TEST_DEV $MD_VOL$SCRATCH_DEV


#source ./common/papyros
#LD_LIBRARY_PATH=/home/hselin/share/evimero/libfuse/build/lib/:$LD_LIBRARY_PATH _mkfs_papyros $TEST_DEV $TEST_SPARE_DEV $TEST_MD_DIR


#LD_LIBRARY_PATH=/home/hselin/share/evimero/libfuse/build/lib/:$LD_LIBRARY_PATH ./check $*
LD_LIBRARY_PATH=/home/hselin/share/evimero/libfuse/build/lib/:$LD_LIBRARY_PATH ./check -b -g quick
