#!/bin/bash -e
set -ex

cd "/home/$FIRST_USER_NAME/maintnode"

# ULDAQ
cd "/home/$FIRST_USER_NAME/"
tar -xvf uldaq.tar.gz
cd libuldaq-1.2.0
./configure && make && make install
rm uldaq.tar.gz
rm -rf libuldaq-1.2.0

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

cd "/home/$FIRST_USER_NAME/maintnode"
sudo -u ${FIRST_USER_NAME} -H bash -c "cd /home/${FIRST_USER_NAME}/maintnode-local-db && poetry install --only main"
