#!/bin/bash -e
set -ex

cd "/home/$FIRST_USER_NAME/maintnode-local-db"
poetry install --no-root --only main

export MAINTNODE_LOCAL_DB_BIN_PATH=$(poetry env info -p)/bin

cp "/home/$FIRST_USER_NAME/maintnode-local-db/maintnode-local-db.service" "/etc/systemd/system/"
cp "/home/$FIRST_USER_NAME/maintnode-local-db/maintnode-local-db-worker.service" "/etc/systemd/system/"


for f in $(ls systemd); do
  cat systemd/$f | envsubst | sudo tee -a "/etc/systemd/system/$f";
done

systemctl enable maintnode-local-db maintnode-local-db-worker
systemctl start maintnode-local-db maintnode-local-db-worker

echo '35 */4 * * * systemctl restart maintnode-local-db-worker.service' >> "/var/spool/cron/crontabs/root"