#!/bin/bash -e

# Enable debugging for troubleshooting
if [[ "$DEBUG" == "true" ]]; then
  set -ex
fi
# Constants
NETWORK_CONFIG_DIR="/etc/systemd/network"
NETWORK_CONFIG_FILE="$NETWORK_CONFIG_DIR/10-static.network"
BACKUP_FILE="$NETWORK_CONFIG_FILE.bak"
PING_TARGET="8.8.8.8"

# Functions

# Print usage instructions
print_usage() {
  echo "Usage: $0 <IP_ADDRESS> <NETMASK> <GATEWAY> <DNS>"
  echo "Example:"
  echo "  $0 192.168.1.100 24 192.168.1.1 8.8.8.8"
}

# Validate IP address format
validate_ip() {
  local ip=$1
  if ! [[ "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    echo "Error: $ip is not a valid IP address."
    exit 1
  fi
}

# Backup the current configuration
backup_config() {
  if [ -f "$NETWORK_CONFIG_FILE" ] && [ ! -f "$BACKUP_FILE" ]; then
    sudo cp "$NETWORK_CONFIG_FILE" "$BACKUP_FILE"
    echo "Backup of current configuration saved to $BACKUP_FILE."
  fi
}

# Restore the previous configuration
restore_config() {
  if [ -f "$BACKUP_FILE" ]; then
    sudo cp "$BACKUP_FILE" "$NETWORK_CONFIG_FILE"
    echo "Previous configuration restored."
    sudo systemctl restart systemd-networkd
  else
    echo "No backup configuration found. Cannot restore."
  fi
}

# Apply the new network configuration
apply_config() {
  local ip=$1
  local netmask=$2
  local gateway=$3
  local dns=$4

  sudo mkdir -p "$NETWORK_CONFIG_DIR"

  sudo bash -c "cat > $NETWORK_CONFIG_FILE" <<EOF
[Match]
Name=eth0

[Network]
Address=$ip/$netmask
Gateway=$gateway
DNS=$dns
EOF

  echo "New network configuration applied."
  sudo systemctl restart systemd-networkd
}

# Test the network connection
test_connection() {
  if ping -c 1 "$PING_TARGET" &> /dev/null; then
    echo "Network connection is active."
    return 0
  else
    echo "Network connection test failed."
    return 1
  fi
}

# Main script logic

# Get inputs
IP_ADDRESS=$1
NETMASK=$2
GATEWAY=$3
DNS=$4

# Validate inputs
if [[ -z "$IP_ADDRESS" || -z "$NETMASK" || -z "$GATEWAY" || -z "$DNS" ]]; then
  echo "Error: All arguments (IP_ADDRESS, NETMASK, GATEWAY, DNS) must be provided."
  print_usage
  exit 1
fi

validate_ip "$IP_ADDRESS"
validate_ip "$GATEWAY"
validate_ip "$DNS"

# Backup current configuration
backup_config

# Apply new configuration
apply_config "$IP_ADDRESS" "$NETMASK" "$GATEWAY" "$DNS"

# Test the connection
if test_connection; then
  echo "Network configuration successful."
else
  echo "Network configuration failed. Reverting to previous configuration."
  restore_config
  exit 1
fi