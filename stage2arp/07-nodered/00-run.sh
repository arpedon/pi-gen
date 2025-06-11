#!/bin/bash -e

ls -la /tmp ${ROOTFS_DIR}/tmp
mkdir -p ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.node-red

install -m 744 files/update-nodejs-and-nodered.sh "${ROOTFS_DIR}/tmp/"