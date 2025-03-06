#!/bin/bash -e

ls -la /tmp ${ROOTFS_DIR}/tmp
install -m 744 files/update-nodejs-and-nodered.sh "${ROOTFS_DIR}/tmp/"