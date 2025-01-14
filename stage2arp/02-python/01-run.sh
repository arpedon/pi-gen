#!/bin/bash -e
set -ex

python3 -m venv ${ROOTFS_DIR}/home/pi/.poetry
${ROOTFS_DIR}/home/pi/.poetry/bin/pip install -U pip setuptools
${ROOTFS_DIR}/home/pi/.poetry/bin/pip install poetry
