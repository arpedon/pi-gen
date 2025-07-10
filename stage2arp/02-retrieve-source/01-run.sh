#!/bin/bash -e
set -ex

rm -rf ${ROOTFS_DIR}/home/$FIRST_USER_NAME/maintnode ${ROOTFS_DIR}/home/$FIRST_USER_NAME/maintnode-local-db ${ROOTFS_DIR}/home/$FIRST_USER_NAME/daqhats
export GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
# Get the v2 branch for now
git clone -b v2 git@github.com:arpedon/maintnode.git "${ROOTFS_DIR}/home/$FIRST_USER_NAME/maintnode"
git clone -b v2 git@github.com:arpedon/maintnode-local-db.git "${ROOTFS_DIR}/home/$FIRST_USER_NAME/maintnode-local-db"
git clone https://github.com/mccdaq/daqhats.git "${ROOTFS_DIR}/home/$FIRST_USER_NAME/daqhats"
wget -O "${ROOTFS_DIR}/home/$FIRST_USER_NAME/libuldaq-1.2.1.tar.bz2" -N https://github.com/mccdaq/uldaq/releases/download/v1.2.1/libuldaq-1.2.1.tar.bz2
on_chroot << EOF
chown -R ${FIRST_USER_NAME}:${FIRST_USER_NAME} /home/${FIRST_USER_NAME}/maintnode
chown -R ${FIRST_USER_NAME}:${FIRST_USER_NAME} /home/${FIRST_USER_NAME}/maintnode-local-db
chown -R ${FIRST_USER_NAME}:${FIRST_USER_NAME} /home/${FIRST_USER_NAME}/daqhats
cd /home/$FIRST_USER_NAME/ && tar -xvjf libuldaq-1.2.1.tar.bz2
EOF
