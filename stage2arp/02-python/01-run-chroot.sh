#!/bin/bash -e
set -ex

export PATH=$PATH:/root/.local/bin
pipx ensurepath
pipx install poetry
poetry --version
which poetry