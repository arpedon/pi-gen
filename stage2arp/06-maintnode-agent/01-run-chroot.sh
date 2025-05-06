#!/bin/bash -e
set -ex

systemctl enable maintnode-agent
systemctl start maintnode-agent