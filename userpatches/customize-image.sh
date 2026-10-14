#!/bin/bash
set -e

# Image customization script executed inside chroot

RELEASE=$1
LINUXFAMILY=$2
BOARD=$3
BUILD_DESKTOP=$4

# Load custom user configuration from overlay if available
if [ -f /etc/custom_user.env ]; then
    source /etc/custom_user.env
    rm -f /etc/custom_user.env
elif [ -f /tmp/overlay/etc/custom_user.env ]; then
    source /tmp/overlay/etc/custom_user.env
fi

TARGET_USER="${DEFAULT_USERNAME:-ubuntu}"
TARGET_PASS="${DEFAULT_PASSWORD:-ubuntu}"
ROOT_PASS="${ROOT_PASSWORD:-ubuntu}"

echo "=== [customize-image] Setting up user: ${TARGET_USER} ==="

# Set root password
echo "root:${ROOT_PASS}" | chpasswd
rm -f /root/.not_logged_in_yet

# Create target user if not present
if ! id "${TARGET_USER}" >/dev/null 2>&1; then
    adduser --quiet --disabled-password --shell /bin/bash --home "/home/${TARGET_USER}" --gecos "${TARGET_USER}" "${TARGET_USER}"
fi

# Set target user password
echo "${TARGET_USER}:${TARGET_PASS}" | chpasswd

# Assign groups
for grp in sudo netdev audio video disk tty users games dialout plugdev input bluetooth systemd-journal ssh docker; do
    if getent group "${grp}" >/dev/null 2>&1; then
        usermod -aG "${grp}" "${TARGET_USER}" 2>/dev/null || true
    fi
done

# Ensure sudo rights
echo "${TARGET_USER} ALL=(ALL:ALL) ALL" > "/etc/sudoers.d/99-${TARGET_USER}"
chmod 0440 "/etc/sudoers.d/99-${TARGET_USER}"

# Remove default 'orangepi' user if different from TARGET_USER
if [ "${TARGET_USER}" != "orangepi" ] && id "orangepi" >/dev/null 2>&1; then
    echo "=== [customize-image] Removing default user 'orangepi' ==="
    pkill -u orangepi 2>/dev/null || true
    deluser --remove-home orangepi 2>/dev/null || true
    rm -f /etc/sudoers.d/*orangepi* || true
fi

# Update autologin configuration to target user in systemd and lightdm
echo "=== [customize-image] Updating autologin to ${TARGET_USER} ==="
find /usr/lib/systemd/system /etc/systemd/system -name "override.conf" -type f -exec sed -i "s/--autologin orangepi/--autologin ${TARGET_USER}/g" {} + 2>/dev/null || true
find /etc/lightdm -type f -exec sed -i "s/autologin-user=orangepi/autologin-user=${TARGET_USER}/g" {} + 2>/dev/null || true

echo "=== [customize-image] User ${TARGET_USER} configured successfully ==="
