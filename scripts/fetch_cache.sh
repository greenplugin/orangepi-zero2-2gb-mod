#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "=== [1/4] Ensuring orangepi-build repo is ready ==="
"${SCRIPT_DIR}/clone_repo.sh"

echo "=== [2/4] Deploying 2GB RAM patches and configs ==="
"${SCRIPT_DIR}/setup_patches.sh"

echo "=== [3/4] Ensuring Docker image is built ==="
docker build -t orangepi-builder:latest -f "${ROOT_DIR}/docker/Dockerfile" "${ROOT_DIR}"

echo "=== [4/4] Pre-fetching toolchains and initialization caches in Docker ==="
docker run --rm --privileged \
    --network host \
    -v "${ROOT_DIR}:/workspace" \
    -v /dev:/dev \
    -v orangepi-zero2-cache:/workspace/orangepi-build/cache \
    -v orangepi-zero2-ccache:/root/.ccache \
    -w /workspace/orangepi-build \
    orangepi-builder:latest \
    bash -c "./build.sh orangepizero2-2gb JUST_INIT=yes USE_TORRENT=no"

echo "=== Cache initialization complete! ==="
