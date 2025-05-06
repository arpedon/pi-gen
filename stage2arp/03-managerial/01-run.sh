#!/bin/bash -e

install -m 644 files/maintnode "${ROOTFS_DIR}/etc/logrotate.d/"
install -m 755 files/network-setup.sh "${ROOTFS_DIR}/usr/local/bin/network-setup"

install -m 644 files/hostapd.conf "${ROOTFS_DIR}/etc/hostapd/hostapd.conf"
install -m 644 files/dnsmasq.conf "${ROOTFS_DIR}/etc/hostapd/dnsmasq.conf"

install -m 644 files/gpio-hotspot.service "${ROOTFS_DIR}/etc/systemd/system/gpio-hotspot.service"
install -m 644 files/config-webapp.service "${ROOTFS_DIR}/etc/systemd/system/config-webapp.service"

echo "net.ipv4.ip_forward=1" >> "${ROOTFS_DIR}/etc/sysctl.conf"

install -m 755 files/gpio_hotspot.py "${ROOTFS_DIR}/usr/local/bin/gpio_hotspot.py"

install -m 755 files/config-webapp.py "${ROOTFS_DIR}/usr/local/bin/config-webapp.py"
install -d files/templates "${ROOTFS_DIR}/usr/local/bin/templates"
