#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

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

echo "=== Target User: ${DEFAULT_USERNAME} ==="

echo "=== [1/3] Ensuring repository and 2GB patches are deployed ==="
"${SCRIPT_DIR}/clone_repo.sh"
"${SCRIPT_DIR}/setup_patches.sh"

echo "=== [2/3] Checking Docker builder image ==="
docker build -t orangepi-builder:latest -f "${ROOT_DIR}/docker/Dockerfile" "${ROOT_DIR}"

echo "=== [3/3] Compiling full OS image (2GB RAM support) inside Docker ==="
docker run --rm --privileged \
    --network host \
    -v "${ROOT_DIR}:/workspace" \
    -v /dev:/dev \
    -v orangepi-zero2-cache:/workspace/orangepi-build/cache \
    -v orangepi-zero2-ccache:/root/.ccache \
    -e DEFAULT_USERNAME="${DEFAULT_USERNAME}" \
    -e DEFAULT_PASSWORD="${DEFAULT_PASSWORD}" \
    -e ROOT_PASSWORD="${ROOT_PASSWORD}" \
    -e OPI_USERNAME="${DEFAULT_USERNAME}" \
    -e OPI_PWD="${DEFAULT_PASSWORD}" \
    -e ROOTPWD="${ROOT_PASSWORD}" \
    -w /workspace/orangepi-build \
    orangepi-builder:latest \
    bash -c "rm -rf output/images/* && ./build.sh orangepizero2-2gb BUILD_OPT=image KERNEL_CONFIGURE=no USE_TORRENT=no OPI_USERNAME='${DEFAULT_USERNAME}' OPI_PWD='${DEFAULT_PASSWORD}' ROOTPWD='${ROOT_PASSWORD}' $* && chown -R $(id -u):$(id -g) output/ userpatches"

echo "=== Image build finished! ==="
echo "Firmware image is located in:"
echo " - Directory: ${ROOT_DIR}/orangepi-build/output/images/"
IMG_FILE=$(find "${ROOT_DIR}/orangepi-build/output/images/" -name "*.img" 2>/dev/null | head -n 1 || true)
if [ -n "${IMG_FILE}" ]; then
    mkdir -p "${ROOT_DIR}/output"
    ln -sf "${IMG_FILE}" "${ROOT_DIR}/output/Orangepizero2_2GB_ubuntu_jammy_server_linux6.1.31.img"
    echo " - Image:     ${IMG_FILE}"
    echo " - Symlink:   ${ROOT_DIR}/output/Orangepizero2_2GB_ubuntu_jammy_server_linux6.1.31.img"
    echo ""
    echo "To flash image to SD card:"
    echo "  sudo dd if=${IMG_FILE} of=/dev/sdX bs=4M status=progress conv=fsync"
fi
