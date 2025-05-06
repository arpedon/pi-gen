#!/bin/bash -e
set -ex

install -m 644 files/maintnode-agent_0.1.1_linux_arm64.tar.gz "${ROOTFS_DIR}/tmp/maintnode-agent.tar.gz"
mkdir -p "${ROOTFS_DIR}/usr/local/share/maintnode-setup"
install -m 644 files/maintnode-agent.service "${ROOTFS_DIR}/usr/local/share/maintnode-setup/maintnode-agent.service"
install -m 755 files/maintnode-setup.sh "${ROOTFS_DIR}/usr/local/bin/maintnode-setup"

# as a temporary workaround, we need to copy the maintnode-agent.service file to /etc/systemd/system
install -m 644 files/maintnode-agent.service "${ROOTFS_DIR}/etc/systemd/system/maintnode-agent.service"

on_chroot << EOF
cd /tmp
tar -xzf maintnode-agent.tar.gz
ls -lR
mv maintnode-agent /usr/local/bin/maintnode-agent
EOF
echo '35 */4 * * * systemctl restart maintnode-local-db-worker.service' >> "${ROOTFS_DIR}/var/spool/cron/crontabs/root"
