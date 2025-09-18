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
  echo "Usage: $0 --maintnode-config-uuid=<uuid> [--mechbase-url=<url>] [--tailscale-auth-key=<key>] [--readonly-filesystem=<true|false>]"
  echo "Required parameters:"
  echo "  --maintnode-config-uuid=<uuid>  UUID for maintnode configuration"
  echo "Optional parameters:"
  echo "  --tailscale-auth-key=<key>      Tailscale authentication key (omit to skip Tailscale setup)"
  echo "  --mechbase-url=<url>            Mechbase server URL (default: $DEFAULT_MECHBASE_SERVER)"
  echo "  --readonly-filesystem=<bool>    Enable readonly filesystem overlay (default: true)"
  echo ""
  echo "Example:"
  echo "  $0 --maintnode-config-uuid=12345678-1234-1234-1234-123456789abc --mechbase-url=https://custom.server.com --readonly-filesystem=false"
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
    envsubst < "$SYSTEMD_DIR/$file" > "/etc/systemd/system/$file"
  done
  systemctl daemon-reload
}

# Restart and check service status
restart_and_check_service() {
  local service=$1
  systemctl enable "$service"
  systemctl start "$service"
  if systemctl is-active --quiet "$service"; then
    echo "$service service is running."
  else
    echo "$service service is not running. Exiting."
    exit 1
  fi
}

# Setup Tailscale with auth key
setup_tailscale() {
  local auth_key=$1
  echo "Setting up Tailscale with provided auth key..."
  if command -v tailscale &> /dev/null; then
    tailscale up --auth-key="$auth_key"
    echo "Tailscale setup completed."
  else
    echo "Error: Tailscale is not installed."
    exit 1
  fi
}

# Setup FRPC with MAINTNODE_ID
setup_frpc() {
  local maintnode_id=$1
  local frpc_config="/usr/local/etc/frp/frpc.ini"

  echo "Setting up FRPC with MAINTNODE_ID: $maintnode_id"

  if [ -f "$frpc_config" ]; then
    export MAINTNODE_ID="$maintnode_id"
    envsubst '$MAINTNODE_ID' < "$frpc_config" > "$frpc_config.tmp" && mv "$frpc_config.tmp" "$frpc_config"
    echo "FRPC configuration updated successfully."
  else
    echo "Warning: FRPC configuration file not found at $frpc_config"
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

# Initialize variables
MAINTNODE_CONFIG_UUID=""
MECHBASE_SERVER="$DEFAULT_MECHBASE_SERVER"
TAILSCALE_AUTH_KEY=""
READONLY_FILESYSTEM="true"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --maintnode-config-uuid=*)
      MAINTNODE_CONFIG_UUID="${1#*=}"
      shift
      ;;
    --mechbase-url=*)
      MECHBASE_SERVER="${1#*=}"
      shift
      ;;
    --tailscale-auth-key=*)
      TAILSCALE_AUTH_KEY="${1#*=}"
      shift
      ;;
    --readonly-filesystem=*)
      READONLY_FILESYSTEM="${1#*=}"
      shift
      ;;
    -h|--help)
      print_usage
      exit 0
      ;;
    *)
      echo "Error: Unknown parameter $1"
      print_usage
      exit 1
      ;;
  esac
done

# Validate required inputs
if [[ -z "$MAINTNODE_CONFIG_UUID" ]]; then
  echo "Error: --maintnode-config-uuid parameter is required."
  print_usage
  exit 1
fi

validate_uuid "$MAINTNODE_CONFIG_UUID"
validate_url "$MECHBASE_SERVER"

# Check internet connection
check_internet_connection

# Setup Tailscale (optional)
if [[ -n "$TAILSCALE_AUTH_KEY" ]]; then
  setup_tailscale "$TAILSCALE_AUTH_KEY"
else
  echo "No Tailscale key provided; skipping Tailscale setup."
fi

# Setup FRPC
setup_frpc "$HOSTNAME"
restart_and_check_service "frpc"

# Substitute variables in systemd files
substitute_systemd_files "$MAINTNODE_CONFIG_UUID" "$MECHBASE_SERVER"

# Restart and check service
restart_and_check_service "$SERVICE_NAME"

# Wait for the configuration file
wait_for_config_file "$CONFIG_FILE_PATH"

# Enable or disable overlay filesystem based on the parameter
if [[ "$READONLY_FILESYSTEM" == "true" ]]; then
  echo "Enabling readonly filesystem overlay..."
  raspi-config nonint do_overlayfs 0
else
  echo "Readonly filesystem overlay disabled."
fi

echo "Maintnode setup completed successfully."
echo "Please reboot your system to apply all changes."
