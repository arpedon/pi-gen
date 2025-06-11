#!/bin/bash -e
set -ex

# Create the config directory if it does not exist
mkdir -p "${ROOTFS_DIR}/usr/local/etc/frp"

# Create the frp bin directory if it does not exist
mkdir -p "${ROOTFS_DIR}/usr/local/bin/frp"

# Install frpc binary
install -m 755 files/frpc "${ROOTFS_DIR}/usr/local/bin/frp/frpc"

# Install frpc config file with variable substitution
envsubst '$FIRST_USER_NAME' < files/frpc.ini > "${ROOTFS_DIR}/usr/local/etc/frp/frpc.ini"

# Install frpc systemd service file with variable substitution
envsubst '$FIRST_USER_NAME' < files/frpc.service > "${ROOTFS_DIR}/lib/systemd/system/frpc.service"
