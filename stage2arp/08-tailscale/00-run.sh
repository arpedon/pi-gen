#!/bin/bash -e

install -d -m 755 "${ROOTFS_DIR}/etc/tailscale"
printf 'TAILSCALE_AUTH_KEY=%s\n' "${TAILSCALE_AUTH_KEY}" > "${ROOTFS_DIR}/etc/tailscale/auth.env"
chmod 600 "${ROOTFS_DIR}/etc/tailscale/auth.env"
install -m 644 files/tailscale-up.service "${ROOTFS_DIR}/etc/systemd/system/tailscale-up.service"
ls ${ROOTFS_DIR}/etc/systemd/system/