#!/bin/bash -e

set -ex

cd /home/${FIRST_USER_NAME}/.node-red
/tmp/update-nodejs-and-nodered.sh --nodered-user=${FIRST_USER_NAME} --confirm-install --confirm-pi --no-init --node18
npm install node-red-dashboard \
  node-red-contrib-modbus \
  node-red-contrib-opcua \
  node-red-node-daemon \
  bcryptjs
chown -R ${FIRST_USER_NAME}:${FIRST_USER_NAME} /home/${FIRST_USER_NAME}/.node-red

systemctl enable nodered.service
systemctl start nodered.service
