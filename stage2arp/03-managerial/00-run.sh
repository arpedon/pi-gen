#!/bin/bash -e

install -m 644 files/maintnode "${ROOTFS_DIR}/etc/logrotate.d/"
install -m 644 files/network-setup.sh "${ROOTFS_DIR}/usr/local/bin/network-setup.sh"