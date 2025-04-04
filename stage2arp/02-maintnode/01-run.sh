#!/bin/bash -e
set -ex

rm -rf ${ROOTFS_DIR}/home/$FIRST_USER_NAME/maintnode ${ROOTFS_DIR}/home/$FIRST_USER_NAME/maintnode-local-db ${ROOTFS_DIR}/home/$FIRST_USER_NAME/daqhats
export GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
git clone git@github.com:arpedon/maintnode.git "${ROOTFS_DIR}/home/$FIRST_USER_NAME/maintnode"
git clone git@github.com:arpedon/maintnode-local-db.git "${ROOTFS_DIR}/home/$FIRST_USER_NAME/maintnode-local-db"
git clone https://github.com/mccdaq/daqhats.git "${ROOTFS_DIR}/home/$FIRST_USER_NAME/daqhats"
on_chroot << EOF
cd /home/${FIRST_USER_NAME}/maintnode-local-db
bash ./install.sh
EOF
install -m 644 files/maintnode-agent_0.1.1_linux_arm64.tar.gz "${ROOTFS_DIR}/tmp/maintnode-agent.tar.gz"
install -m 644 files/maintnode-agent.service "${ROOTFS_DIR}/etc/systemd/system/maintnode-agent.service"
on_chroot << EOF
cd /tmp
tar -xzf maintnode-agent.tar.gz
ls -lR
mv maintnode-agent /usr/local/bin/maintnode-agent
EOF
