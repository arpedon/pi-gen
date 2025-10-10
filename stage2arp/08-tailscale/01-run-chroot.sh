#!/bin/bash -e

curl -fsSL https://tailscale.com/install.sh | sh

systemctl enable tailscale-up.service