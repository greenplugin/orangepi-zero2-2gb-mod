#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ORANGEPI_BUILD_DIR="${ROOT_DIR}/orangepi-build"

# Load .env if present
if [ -f "${ROOT_DIR}/.env" ]; then
    echo "Loading configuration from ${ROOT_DIR}/.env"
    set -a
    source "${ROOT_DIR}/.env"
    set +a
fi

DEFAULT_USERNAME="${DEFAULT_USERNAME:-ubuntu}"
DEFAULT_PASSWORD="${DEFAULT_PASSWORD:-ubuntu}"
ROOT_PASSWORD="${ROOT_PASSWORD:-ubuntu}"

echo "=== [1/4] Ensuring orangepi-build directories ==="
mkdir -p "${ORANGEPI_BUILD_DIR}/userpatches/u-boot/u-boot-sunxi"
mkdir -p "${ORANGEPI_BUILD_DIR}/userpatches/u-boot/u-boot-sun50iw9"
mkdir -p "${ORANGEPI_BUILD_DIR}/userpatches/overlay/etc"

echo "=== [2/4] Installing U-Boot 2GB RAM patch ==="
cp -v "${ROOT_DIR}/userpatches/u-boot/u-boot-sunxi/"*.patch \
      "${ORANGEPI_BUILD_DIR}/userpatches/u-boot/u-boot-sunxi/"

echo "=== [3/4] Copying preset configurations & customize-image script ==="
cp -v "${ROOT_DIR}/userpatches/config-orangepizero2-2gb.conf" \
      "${ORANGEPI_BUILD_DIR}/userpatches/"

cp -v "${ROOT_DIR}/userpatches/customize-image.sh" \
      "${ORANGEPI_BUILD_DIR}/userpatches/"
chmod +x "${ORANGEPI_BUILD_DIR}/userpatches/customize-image.sh"

# Create custom user environment for chroot customization
cat <<EOF > "${ORANGEPI_BUILD_DIR}/userpatches/overlay/etc/custom_user.env"
DEFAULT_USERNAME="${DEFAULT_USERNAME}"
DEFAULT_PASSWORD="${DEFAULT_PASSWORD}"
ROOT_PASSWORD="${ROOT_PASSWORD}"
EOF

echo "=== [4/4] Setting user config in orangepi-build ==="
if [ ! -f "${ORANGEPI_BUILD_DIR}/userpatches/config-default.conf" ]; then
    cp -v "${ROOT_DIR}/userpatches/config-orangepizero2-2gb.conf" \
          "${ORANGEPI_BUILD_DIR}/userpatches/config-default.conf"
fi

echo "Patches, configurations, and user credentials (${DEFAULT_USERNAME}) successfully deployed into orangepi-build."
