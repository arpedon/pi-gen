#!/bin/bash -e

install -m 644 files/maintnode "${ROOTFS_DIR}/etc/logrotate.d/"
install -m 755 files/network-setup.sh "${ROOTFS_DIR}/usr/local/bin/network-setup"

HOSTAPD_DIR="${ROOTFS_DIR}/etc/hostapd"
HOSTAPD_TEMPLATE="${HOSTAPD_DIR}/hostapd.conf.template"
install -d "${HOSTAPD_DIR}"
install -m 644 files/hostapd.conf "${HOSTAPD_TEMPLATE}"
install -m 755 files/render-hostapd-ssid.sh "${ROOTFS_DIR}/usr/local/bin/render-hostapd-ssid"
install -m 644 files/hostapd-ssid.service "${ROOTFS_DIR}/etc/systemd/system/hostapd-ssid.service"
install -d "${ROOTFS_DIR}/etc/systemd/system/hostapd.service.d"
install -m 644 files/hostapd.service.d/override.conf "${ROOTFS_DIR}/etc/systemd/system/hostapd.service.d/override.conf"
install -d "${ROOTFS_DIR}/etc/systemd/system/multi-user.target.wants"
ln -sf ../hostapd-ssid.service "${ROOTFS_DIR}/etc/systemd/system/multi-user.target.wants/hostapd-ssid.service"
# dnsmasq reads from /etc/dnsmasq.conf and /etc/dnsmasq.d/*.conf
install -d "${ROOTFS_DIR}/etc/dnsmasq.d"
install -m 644 files/dnsmasq.conf "${ROOTFS_DIR}/etc/dnsmasq.d/hotspot.conf"

install -m 644 files/gpio-hotspot.service "${ROOTFS_DIR}/etc/systemd/system/gpio-hotspot.service"
install -m 644 files/config-webapp.service "${ROOTFS_DIR}/etc/systemd/system/config-webapp.service"

echo "net.ipv4.ip_forward=1" >> "${ROOTFS_DIR}/etc/sysctl.conf"

install -m 755 files/gpio_hotspot.py "${ROOTFS_DIR}/usr/local/bin/gpio_hotspot.py"

install -m 755 files/config-webapp.py "${ROOTFS_DIR}/usr/local/bin/config-webapp.py"
install -d "${ROOTFS_DIR}/usr/local/bin/templates"
install -m 644 files/templates/index.html "${ROOTFS_DIR}/usr/local/bin/templates/index.html"

# Provide default DHCP on eth0 for systemd-networkd
install -d "${ROOTFS_DIR}/etc/systemd/network"
install -m 644 files/10-eth0.network "${ROOTFS_DIR}/etc/systemd/network/10-eth0.network"

# Give wlan0 a static IP for the hotspot
install -m 644 files/30-wlan0-ap.network "${ROOTFS_DIR}/etc/systemd/network/30-wlan0-ap.network"
