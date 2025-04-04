#!/bin/bash -e
set -ex

printf "y/ny" | bash <(curl -sL https://raw.githubusercontent.com/node-red/linux-installers/master/deb/update-nodejs-and-nodered) --confirm-install --confirm-root --confirm-pi --nodered-user=$FIRST_USER_NAME
# mkdir -p ~/.node-red
# cp "${ROOTFS_DIR}/home/$FIRST_USER_NAME/maintnode/installation/node-red/*" "${ROOTFS_DIR}/.node-red/"
# cd "${ROOTFS_DIR}/home/$FIRST_USER_NAME/.node-red/"

echo "Start Node-RED on boot:"
systemctl enable nodered.service
systemctl start nodered.service
