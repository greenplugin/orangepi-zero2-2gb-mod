#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ORANGEPI_BUILD_DIR="${ROOT_DIR}/orangepi-build"
REPO_URL="https://github.com/orangepi-xunlong/orangepi-build.git"

echo "=== [1/2] Checking orangepi-build repository ==="
if [ -d "${ORANGEPI_BUILD_DIR}/.git" ]; then
    echo "orangepi-build already cloned in ${ORANGEPI_BUILD_DIR}."
    echo "Updating repository index..."
    (cd "${ORANGEPI_BUILD_DIR}" && git fetch --depth=1 origin || true)
else
    echo "Cloning official orangepi-build repository..."
    git clone --depth=1 "${REPO_URL}" "${ORANGEPI_BUILD_DIR}"
fi

echo "=== [2/2] Setup orangepi-build directories ==="
mkdir -p "${ORANGEPI_BUILD_DIR}/userpatches"
mkdir -p "${ORANGEPI_BUILD_DIR}/output"
mkdir -p "${ORANGEPI_BUILD_DIR}/cache"

echo "orangepi-build repository is ready."
