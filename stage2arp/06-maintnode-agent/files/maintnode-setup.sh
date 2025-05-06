#!/bin/bash -e

# Enable debugging for troubleshooting
if [[ "$DEBUG" == "true" ]]; then
  set -ex
fi

# Constants
DEFAULT_MECHBASE_SERVER="https://mechbase.arpedon.com"
CONFIG_FILE_PATH="/home/pi/config/maintnode.yaml"
SYSTEMD_DIR="/usr/local/share/maintnode-setup/systemd"
SERVICE_NAME="maintnode-agent"
PING_TARGET="8.8.8.8"

# Functions

# Print usage instructions
print_usage() {
  echo "Usage: $0 <MAINTNODE_CONFIG_UUID> <MECHBASE_SERVER>"
  echo "Example MECHBASE_SERVER values:"
  echo "  - $DEFAULT_MECHBASE_SERVER (default cloud server)"
  echo "  - http://<on-premise-server-address> (for on-premise installations)"
}

# Validate UUID format
validate_uuid() {
  local uuid=$1
  if ! [[ "$uuid" =~ ^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$ ]]; then
    echo "Error: MAINTNODE_CONFIG_UUID must be a valid UUID."
    exit 1
  fi
}

# Validate URL format
validate_url() {
  local url=$1
  if ! [[ "$url" =~ ^https?://[a-zA-Z0-9.-]+(:[0-9]+)?(/.*)?$ ]]; then
    echo "Error: MECHBASE_SERVER must be a valid URL (e.g., $DEFAULT_MECHBASE_SERVER)."
    exit 1
  fi
}

# Check internet connectivity
check_internet_connection() {
  if ping -c 1 "$PING_TARGET" &> /dev/null; then
    echo "Internet connection is active."
  else
    echo "No internet connection. Exiting."
    exit 1
  fi
}

# Substitute variables in systemd files
substitute_systemd_files() {
  local uuid=$1
  local server=$2

  export MAINTNODE_CONFIG_UUID="$uuid"
  export MECHBASE_SERVER="$server"
  
  for file in $(ls "$SYSTEMD_DIR"); do
    envsubst <<< "$uuid $server" < "$SYSTEMD_DIR/$file" | sudo tee "/etc/systemd/system/$file" > /dev/null
  done
  systemctl daemon-reload
}

# Restart and check service status
restart_and_check_service() {
  local service=$1
  systemctl restart "$service"
  if systemctl is-active --quiet "$service"; then
    echo "$service service is running."
  else
    echo "$service service is not running. Exiting."
    exit 1
  fi
}

# Wait for the configuration file to be downloaded
wait_for_config_file() {
  local file_path=$1
  while ! [ -s "$file_path" ]; do
    echo "Config file not found or empty. Retrying..."
    sleep 1
  done
  echo "Config file is present and filled."
  systemctl restart maintnode-local-db maintnode-local-db-worker
}

# Main script logic

# Get inputs
MAINTNODE_CONFIG_UUID=$1
MECHBASE_SERVER=$2

# Validate inputs
if [[ -z "$MAINTNODE_CONFIG_UUID" || -z "$MECHBASE_SERVER" ]]; then
  echo "Error: Both MAINTNODE_CONFIG_UUID and MECHBASE_SERVER must be provided as arguments."
  print_usage
  exit 1
fi

validate_uuid "$MAINTNODE_CONFIG_UUID"
validate_url "$MECHBASE_SERVER"

# Check internet connection
check_internet_connection

# Substitute variables in systemd files
substitute_systemd_files "$MAINTNODE_CONFIG_UUID" "$MECHBASE_SERVER"

# Restart and check service
restart_and_check_service "$SERVICE_NAME"

# Wait for the configuration file
wait_for_config_file "$CONFIG_FILE_PATH"