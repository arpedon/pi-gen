#!/bin/bash -e
set -ex

install -m 644 files/maintnode-agent_0.1.1_linux_arm64.tar.gz "${ROOTFS_DIR}/tmp/maintnode-agent.tar.gz"
install -m 644 files/maintnode-agent.service "${ROOTFS_DIR}/etc/systemd/system/maintnode-agent.service"
install -m 644 files/maintnode-agent-setup.sh "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/maintnode-agent-setup.sh"

on_chroot << EOF
cd /tmp
tar -xzf maintnode-agent.tar.gz
ls -lR
mv maintnode-agent /usr/local/bin/maintnode-agent
EOF
echo '35 */4 * * * systemctl restart maintnode-local-db-worker.service' >> "${ROOTFS_DIR}/var/spool/cron/crontabs/root"
