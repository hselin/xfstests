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
export MD_LOG=/dev/shm/xfstests_logs
export WL_VOL=/dev/shm/xfstests/wl
export FM_VOL=/dev/shm/xfstests/fm

export FSTYP=papyros

if [[ -z ${TEST_DEV} ]]; then export TEST_DEV=/dev/loop100; fi
if [[ -z ${TEST_SPARE_DEV} ]]; then export TEST_SPARE_DEV=/dev/loop101; fi
export TEST_DIR=/mnt/xfstests/test_dir
export TEST_MD_DIR=$MD_VOL$TEST_DEV
export TEST_WL_DIR=$WL_VOL$TEST_DEV
export TEST_FM_DIR=$FM_VOL$TEST_DEV

#SCRATCH_DEV needs to be CMR so dm-thin can be created
#May  5 06:25:22 corfu kernel: [13013.664214] device-mapper: table: 253:0: start=10240 not aligned to h/w zone size 524288 of sde
#May  5 06:25:22 corfu kernel: [13013.664215] device-mapper: core: Cannot calculate initial queue limits
#May  5 06:25:22 corfu kernel: [13013.664217] device-mapper: ioctl: unable to set up device queue for new table.
if [[ -z ${SCRATCH_DEV} ]]; then export SCRATCH_DEV=/dev/loop102; fi
if [[ -z ${SCRATCH_SPARE_DEV} ]]; then export SCRATCH_SPARE_DEV=/dev/loop103; fi

export SCRATCH_MNT=/mnt/xfstests/scratch_dir
export SCRATCH_MD_DIR=$MD_VOL$SCRATCH_DEV
export SCRATCH_WL_DIR=$WL_VOL$SCRATCH_DEV
export SCRATCH_FM_DIR=$FM_VOL$SCRATCH_DEV

export PAPYROS_TEMP_MNT=/mnt/tmp

if [[ -z ${BASE_PATH} ]]; then export BASE_PATH=/home/hselin/share; fi

export HERACLES_PATH=$BASE_PATH/heracles/src

export PAPYROS_TEST_FS_MOUNT_OPTIONS="-o kernelcache,0readbuffer"

export RECREATE_TEST_DEV=true

export LIB_FUSE_PATH=$BASE_PATH/libfuse/build/lib/

if [[ -v HERACLES_IN_CONTAINER ]]; then
    if [ $HERACLES_IN_CONTAINER -eq 1 ]; then
	echo "Testing heracles as container"
	if [[ ! -v DOCKER_IMAGE_TAG ]]; then
	    echo "HERACLES_IN_CONTAINER is 1 but DOCKER_IMAGE_TAG undefined"
	    exit 1
	fi
	if [[ ! -v DOCKER_DEPOT ]]; then
	    echo "HERACLES_IN_CONTAINER is 1 but DOCKER_DEPOT undefined"
	    exit 1
	fi
	export CONTAINER_IMAGE=$DOCKER_DEPOT:$DOCKER_IMAGE_TAG
    else
	export HERACLES_IN_CONTAINER=0
    fi
else
    export HERACLES_IN_CONTAINER=0
fi

if [[ -v LICENSE_FILE ]]; then
    export HERACLES_LICENSE_OPT="--mount type=bind,src=/etc/machine-id,dst=/etc/machine-id,bind-propagation=rslave --mount type=bind,src=$LICENSE_FILE,dst=/license,bind-propagation=rslave"
else
    export HERACLES_LICENSE_OPT=""
fi

umount $TEST_DIR
umount $SCRATCH_MNT
umount $PAPYROS_TEMP_MNT

#echo "mkdir -p $TEST_DIR $SCRATCH_MNT $MD_LOG $MD_VOL$TEST_DEV $MD_VOL$SCRATCH_DEV $PAPYROS_TEMP_MNT $SCRATCH_FM_DIR $TEST_FM_DIR"
mkdir -p $TEST_DIR $SCRATCH_MNT $MD_LOG $MD_VOL$TEST_DEV $MD_VOL$SCRATCH_DEV $PAPYROS_TEMP_MNT $SCRATCH_FM_DIR $TEST_FM_DIR

source ./common/papyros

LD_LIBRARY_PATH=$LIB_FUSE_PATH:$LD_LIBRARY_PATH _mkfs_papyros $TEST_DEV $TEST_SPARE_DEV $TEST_MD_DIR $TEST_WL_DIR
LD_LIBRARY_PATH=$LIB_FUSE_PATH:$LD_LIBRARY_PATH _mkfs_papyros $SCRATCH_DEV $SCRATCH_SPARE_DEV $SCRATCH_MD_DIR $SCRATCH_WL_DIR


if [ $# -eq 0 ]; then
    LD_LIBRARY_PATH=$LIB_FUSE_PATH:$LD_LIBRARY_PATH ./check -b -g quick
else
    LD_LIBRARY_PATH=$LIB_FUSE_PATH:$LD_LIBRARY_PATH ./check "$@"
fi

