#!/bin/bash -e
set -ex

rm -rf ${ROOTFS_DIR}/home/pi/maintnode ${ROOTFS_DIR}/home/pi/maintnode-local-db
export GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
git clone git@github.com:arpedon/maintnode.git "${ROOTFS_DIR}/home/pi/maintnode"
git clone git@github.com:arpedon/maintnode-local-db.git "${ROOTFS_DIR}/home/pi/maintnode-local-db"

install -m 0755 -d ${ROOTFS_DIR}/etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o ${ROOTFS_DIR}/etc/apt/keyrings/docker.asc
chmod a+r ${ROOTFS_DIR}/etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=arm64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian bookworm stable" | \
  tee ${ROOTFS_DIR}/etc/apt/sources.list.d/docker.list > /dev/null

on_chroot apt-key add - < files/docker.asc
on_chroot << EOF
apt-get update
EOF
