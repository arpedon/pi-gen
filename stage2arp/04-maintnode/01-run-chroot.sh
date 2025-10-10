#!/bin/bash -e
set -ex

# ULDAQ
cd "/home/$FIRST_USER_NAME/libuldaq-1.2.1"
echo "Building and installing uldaq library"
echo
./configure && make && make install
echo

rm "/home/$FIRST_USER_NAME/libuldaq-1.2.1.tar.bz2"
rm -rf "/home/$FIRST_USER_NAME/libuldaq-1.2.1"

# DaqHATs
cd "/home/$FIRST_USER_NAME/daqhats"
# Build / install the C library and headers
echo "Building and installing daqhats library"
echo
make -C lib all
if [ $? -ne 0 ]; then
   echo "Library build failed"
   exit 1
fi
make -C lib install
if [ $? -ne 0 ]; then
   echo "Library install failed"
   exit 1
fi
make -C lib clean

echo

# Build / install tools
echo "Building and installing tools"
echo
make -C tools all
if [ $? -ne 0 ]; then
   echo "Tools build failed"
   exit 1
fi
make -C tools install
if [ $? -ne 0 ]; then
   echo "Tools install failed"
   exit 1
fi
make -C tools clean

rm -rf "/home/$FIRST_USER_NAME/daqhats"

sed -i '/^SYS=\/sys\/class\/i2c-adapter\/i2c-\$BUS$/{
    s/.*/SYS=\/sys\/class\/i2c-adapter\/i2c-\$BUS\
if [ ! -d "\$SYS" ]; then\
   SYS=\/sys\/class\/i2c-dev\/i2c-\$BUS\/device\
fi/
}' "/usr/local/bin/daqhats_read_eeproms"


chown -R ${FIRST_USER_NAME}:${FIRST_USER_NAME} /home/${FIRST_USER_NAME}/maintnode

cd "/home/$FIRST_USER_NAME/maintnode"
sudo -u ${FIRST_USER_NAME} -H bash -c "cd /home/${FIRST_USER_NAME}/maintnode && poetry install --only main"

