#!/bin/bash -e
set -ex

python3 -m venv ${ROOTFS_DIR}/home/pi/.poetry
/home/pi/.poetry/bin/pip install -U pip setuptools
/home/pi/.poetry/bin/pip install poetry
ln -s /home/pi/.poetry/bin/poetry /usr/local/bin/poetry
