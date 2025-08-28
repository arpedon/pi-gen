#!/bin/bash -e
set -ex

sysctl -p

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
# Allow forwarding between wlan0 and eth0 for hotspot routing
iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables-save > /etc/iptables.ipv4.nat

# Ensure /etc/rc.local exists and is executable
if [ ! -f /etc/rc.local ]; then
  echo "#!/bin/sh -e" > /etc/rc.local
  echo "exit 0" >> /etc/rc.local
  chmod +x /etc/rc.local
fi

# Add the line to /etc/rc.local before "exit 0"
sed -i '/^exit 0/i iptables-restore < /etc/iptables.ipv4.nat' /etc/rc.local

# Disable NetworkManager
systemctl disable NetworkManager
systemctl mask NetworkManager

# Enable systemd-networkd and systemd-networkd-wait-online
systemctl enable systemd-networkd systemd-networkd-wait-online

# Hotspot on-demand: ensure hostapd/dnsmasq/config-webapp are disabled by default
systemctl disable hostapd || true
systemctl disable dnsmasq || true
systemctl disable config-webapp || true

# Enable GPIO controller to allow toggling hotspot on demand
systemctl enable gpio-hotspot
