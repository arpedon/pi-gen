set -ex

mkdir -p "${ROOTFS_DIR}/usr/local/share/maintnode-setup/systemd"
install -m 755 files/maintnode-setup.sh "${ROOTFS_DIR}/usr/local/bin/maintnode-setup"