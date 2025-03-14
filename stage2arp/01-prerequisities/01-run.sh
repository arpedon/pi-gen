#!/bin/bash -e
set -ex

rm -rf ${ROOTFS_DIR}/home/$FIRST_USER_NAME/maintnode ${ROOTFS_DIR}/home/$FIRST_USER_NAME/maintnode-local-db ${ROOTFS_DIR}/home/$FIRST_USER_NAME/daqhats
export GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
git clone git@github.com:arpedon/maintnode.git "${ROOTFS_DIR}/home/$FIRST_USER_NAME/maintnode"
git clone git@github.com:arpedon/maintnode-local-db.git "${ROOTFS_DIR}/home/$FIRST_USER_NAME/maintnode-local-db"
git clone https://github.com/mccdaq/daqhats.git "${ROOTFS_DIR}/home/$FIRST_USER_NAME/daqhats"
