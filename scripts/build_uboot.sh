#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "=== [1/3] Ensuring repository and 2GB patches are deployed ==="
"${SCRIPT_DIR}/clone_repo.sh"
"${SCRIPT_DIR}/setup_patches.sh"

echo "=== [2/3] Checking Docker builder image ==="
docker build -t orangepi-builder:latest -f "${ROOT_DIR}/docker/Dockerfile" "${ROOT_DIR}"

echo "=== [3/3] Compiling U-Boot & SPL (2GB RAM support) inside Docker ==="
docker run --rm --privileged \
    --network host \
    -v "${ROOT_DIR}:/workspace" \
    -v /dev:/dev \
    -v orangepi-zero2-cache:/workspace/orangepi-build/cache \
    -w /workspace/orangepi-build \
    orangepi-builder:latest \
    bash -c "rm -rf output/debs/u-boot && ./build.sh orangepizero2-2gb BUILD_OPT=u-boot KERNEL_CONFIGURE=no USE_TORRENT=no $* && chown -R $(id -u):$(id -g) output/ userpatches u-boot 2>/dev/null || true"

echo "=== Compilation finished! ==="
mkdir -p "${ROOT_DIR}/output"
if [ -f "${ROOT_DIR}/orangepi-build/u-boot/v2021.10-sunxi/u-boot-sunxi-with-spl.bin" ]; then
    cp -v "${ROOT_DIR}/orangepi-build/u-boot/v2021.10-sunxi/u-boot-sunxi-with-spl.bin" "${ROOT_DIR}/u-boot-sunxi-with-spl.bin"
elif [ -d "${ROOT_DIR}/orangepi-build/output/debs/u-boot" ]; then
    DEB_FILE=$(ls -t "${ROOT_DIR}/orangepi-build/output/debs/u-boot/"*.deb | head -n 1)
    dpkg-deb -x "${DEB_FILE}" /tmp/deb_extract
    find /tmp/deb_extract -name "u-boot-sunxi-with-spl.bin" -exec cp -v {} "${ROOT_DIR}/u-boot-sunxi-with-spl.bin" \;
    rm -rf /tmp/deb_extract
fi

echo ""
echo "=== READY FOR FAST FLASHING ==="
echo "Binary: ${ROOT_DIR}/u-boot-sunxi-with-spl.bin"
echo ""
echo "To flash directly onto existing SD card (takes 1 second):"
echo "  sudo dd if=${ROOT_DIR}/u-boot-sunxi-with-spl.bin of=/dev/sdX bs=1k seek=8 conv=fsync"
echo "  (Replace /dev/sdX with your SD card device, e.g. /dev/sdb or /dev/mmcblk0)"

