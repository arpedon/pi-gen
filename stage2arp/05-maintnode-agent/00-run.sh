#!/bin/bash -e
set -ex

cp "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/maintnode/installation/bin/maintnode-agent" "${ROOTFS_DIR}/usr/local/bin/maintnode-agent"
chmod 0755 "${ROOTFS_DIR}/usr/local/bin/maintnode-agent"
cp "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/maintnode/installation/templates/maintnode-agent.service.j2" "${ROOTFS_DIR}/etc/systemd/system/maintnode-agent.service"
sed -i -e 's/{{ MECHBASE_HOST }}/$TARGET_HOSTNAME/g' "${ROOTFS_DIR}/etc/systemd/system/maintnode-agent.service"

echo '35 */4 * * * systemctl restart maintnode-agent.service' >> "${ROOTFS_DIR}/var/spool/cron/crontabs/root"