#!/bin/bash -e
set -ex

cd /home/${FIRST_USER_NAME}/maintnode-local-db
chown -R ${FIRST_USER_NAME}:${FIRST_USER_NAME} /home/${FIRST_USER_NAME}/maintnode-local-db

cd "/home/$FIRST_USER_NAME/maintnode-local-db"
sudo -u ${FIRST_USER_NAME} -H bash -c "cd /home/${FIRST_USER_NAME}/maintnode-local-db && poetry install --no-root --only main"

export MAINTNODE_LOCAL_DB_BIN_PATH=$(sudo -u ${FIRST_USER_NAME} -H bash -c "cd /home/${FIRST_USER_NAME}/maintnode-local-db && poetry env info -p")/bin

mkdir -p "/media/data"

for file in $(ls systemd); do
  envsubst '$MAINTNODE_LOCAL_DB_BIN_PATH$FIRST_USER_NAME' < "systemd/$file" | sudo tee "/etc/systemd/system/$file" > /dev/null
done

systemctl enable maintnode-local-db maintnode-local-db-worker

echo '35 */4 * * * systemctl restart maintnode-local-db-worker.service' >> "/var/spool/cron/crontabs/root"


