#!/bin/bash -e

set -ex

/tmp/update-nodejs-and-nodered.sh --confirm-root --confirm-install --confirm-pi --no-init --node18

mkdir -p /home/pi/.node-red && cd /home/pi/.node-red
npm install node-red-dashboard \
  node-red-contrib-modbus \
  node-red-contrib-opcua \
  node-red-node-daemon \
  bcryptjs
