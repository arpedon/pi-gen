#!/bin/bash
set -euo pipefail

TEMPLATE="/etc/hostapd/hostapd.conf.template"
DEST="/etc/hostapd/hostapd.conf"
MARKER="/var/lib/hostapd/ssid-configured"

if [ ! -f "${TEMPLATE}" ]; then
    exit 0
fi

HOSTNAME="$(hostnamectl --static 2>/dev/null || cat /etc/hostname)"

python3 - "$TEMPLATE" "$DEST" "$HOSTNAME" <<'PY'
import pathlib
import sys

template_path, dest_path, hostname = sys.argv[1:]
template = pathlib.Path(template_path).read_text()
pathlib.Path(dest_path).write_text(template.replace("${TARGET_HOSTNAME}", hostname))
PY

chmod 644 "${DEST}"
install -d "$(dirname "${MARKER}")"
touch "${MARKER}"
