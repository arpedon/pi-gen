#!/bin/bash -e
set -ex

sysctl -p

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
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