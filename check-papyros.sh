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
#export TEST_DEV=/dev/sda
export TEST_SPARE_DEV=/dev/loop1
export TEST_DIR=/mnt/xfstests/test_dir
export TEST_MD_DIR=$MD_VOL$TEST_DEV

export SCRATCH_DEV=/dev/loop2
#export SCRATCH_DEV=/dev/sdb
export SCRATCH_SPARE_DEV=/dev/loop3
export SCRATCH_MNT=/mnt/xfstests/scratch_dir
export SCRATCH_MD_DIR=$MD_VOL$SCRATCH_DEV

export PAPYROS_TEMP_MNT=/mnt/tmp

export HERACLES_PATH=/home/hselin/share/evimero/heracles/src

export PAPYROS_TEST_FS_MOUNT_OPTIONS="-o kernelcache,0readbuffer"
#export PAPYROS_TEST_FS_MOUNT_OPTIONS="-o 0readbuffer"


export RECREATE_TEST_DEV=true


umount $TEST_DIR
umount $SCRATCH_MNT
umount $PAPYROS_TEMP_MNT

mkdir -p $TEST_DIR $SCRATCH_MNT $MD_VOL$TEST_DEV $MD_VOL$SCRATCH_DEV $PAPYROS_TEMP_MNT


source ./common/papyros
LD_LIBRARY_PATH=/home/hselin/share/evimero/libfuse/build/lib/:$LD_LIBRARY_PATH _mkfs_papyros $TEST_DEV $TEST_SPARE_DEV $TEST_MD_DIR
LD_LIBRARY_PATH=/home/hselin/share/evimero/libfuse/build/lib/:$LD_LIBRARY_PATH _mkfs_papyros $SCRATCH_DEV $SCRATCH_SPARE_DEV $SCRATCH_MD_DIR

#LD_LIBRARY_PATH=/home/hselin/share/evimero/libfuse/build/lib/:$LD_LIBRARY_PATH _papyros_mount $SCRATCH_DEV $SCRATCH_MNT
#exit


#LD_LIBRARY_PATH=/home/hselin/share/evimero/libfuse/build/lib/:$LD_LIBRARY_PATH ./check $*
LD_LIBRARY_PATH=/home/hselin/share/evimero/libfuse/build/lib/:$LD_LIBRARY_PATH ./check -b -g quick
#LD_LIBRARY_PATH=/home/hselin/share/evimero/libfuse/build/lib/:$LD_LIBRARY_PATH ./check generic/451
#LD_LIBRARY_PATH=/home/hselin/share/evimero/libfuse/build/lib/:$LD_LIBRARY_PATH ./check generic/257



#/usr/bin/timeout -s TERM 30s /home/hselin/share/evimero/xfstests/src/aio-dio-regress/aio-dio-cycle-write -c 999999 -b 655360 /home/hselin/share/evimero/heracles/mnt/foo




#generic/124 \
#LD_LIBRARY_PATH=/home/hselin/share/evimero/libfuse/build/lib/:$LD_LIBRARY_PATH ./check \
#generic/126 \
#generic/128 \
#generic/129






# LD_LIBRARY_PATH=/home/hselin/share/evimero/libfuse/build/lib/:$LD_LIBRARY_PATH ./check \
# generic/322 \
# generic/324 \
# generic/325 \
# generic/326 \
# generic/327 \
# generic/328 \
# generic/329 \
# generic/330 \
# generic/331 \
# generic/332 \
# generic/335 \
# generic/336 \
# generic/337 \
# generic/338 \
# generic/341 \
# generic/342 \
# generic/343 \
# generic/346 \
# generic/347 \
# generic/348


#LD_LIBRARY_PATH=/home/hselin/share/evimero/libfuse/build/lib/:$LD_LIBRARY_PATH ./check \
#generic/346 \
#generic/347 \
#generic/348
