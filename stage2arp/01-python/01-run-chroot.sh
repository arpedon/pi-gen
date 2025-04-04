#!/bin/bash -e
set -ex

python3 -m venv /home/${FIRST_USER_NAME}/.poetry
/home/${FIRST_USER_NAME}/.poetry/bin/pip install -U pip setuptools
/home/${FIRST_USER_NAME}/.poetry/bin/pip install poetry
ln -fs /home/${FIRST_USER_NAME}/.poetry/bin/poetry /usr/local/bin/poetry
