#!/bin/bash

################################################################################
# SCRIPT NAME: maintain.sh
# DESCRIPTION: Automates Ubuntu updates + direct-installed UniFi Network Application
#              - Bypasses backup prompt
#              - Keeps existing config files
#              - Tracks UniFi version changes via dpkg/awk
#              - Verifies and restarts UniFi service if needed
#              - Reboots only when required (e.g., kernel update)
################################################################################

# Prevents Ubuntu from popping up interactive windows or asking questions.
# This ensures the script doesn't get stuck waiting for a user to click "OK".
export DEBIAN_FRONTEND=noninteractive

# Defines where the log file is stored. $HOME automatically points to the 
# folder of the user running the script (e.g., /home/YOURUSERNAME/)
LOG_FILE="$HOME/maintenance.log"

# This line ensures every message printed by the script is both shown on your 
# screen and saved to the log file for later review if needed.
exec > >( /usr/bin/tee -a "$LOG_FILE" ) 2>&1

echo "=========================================================="
echo "MAINTENANCE START: $(/usr/bin/date +"%Y-%m-%d %H:%M:%S")"
echo "=========================================================="

### 1. Pre-seed UniFi backup confirmation
### UniFi updates usually stop and ask: "Do you have a backup?" (The Purple Screen).
### This command tells the system the answer is already "Yes" so it can continue.
echo "[1/4] Pre-seeding UniFi backup confirmation..."
echo "unifi unifi/has_backup boolean true" | /usr/bin/sudo /usr/bin/debconf-set-selections

# 2. Update system and UniFi
echo "[2/4] Updating Ubuntu and UniFi packages..."

# Capture version before update
# Checks the database of installed programs to find the current version of UniFi.
BEFORE_VER=$(/usr/bin/dpkg -l unifi 2>/dev/null | /usr/bin/awk '/^ii/ {print $3}')
echo "Current UniFi version: ${BEFORE_VER:-Unknown}"

# 'apt-get update' refreshes the list of available updates.
# 'full-upgrade' installs them. 
# '--force-confold' tells Ubuntu: "If a config file changed, keep my old version."
if /usr/bin/sudo /usr/bin/apt-get update && \
   /usr/bin/sudo /usr/bin/apt-get full-upgrade -y -o Dpkg::Options::="--force-confold"; then
    echo "SUCCESS: All packages updated successfully."
    
    # Capture version after update and compare
    # Checks the UniFi version again after the update to see if it changed.
    AFTER_VER=$(/usr/bin/dpkg -l unifi 2>/dev/null | /usr/bin/awk '/^ii/ {print $3}')
    
    if [ -n "$AFTER_VER" ]; then
        if [ "$BEFORE_VER" != "$AFTER_VER" ]; then
            echo "UniFi UPDATED: $BEFORE_VER -> $AFTER_VER"
        else
            echo "UniFi version unchanged: $AFTER_VER"
        fi
    else
        echo "WARNING: Could not determine UniFi version after update."
    fi

    # Then cleans up old, unneeded system files to save disk space.
    /usr/bin/sudo /usr/bin/apt-get autoremove -y
    /usr/bin/sudo /usr/bin/apt-get autoclean -y
    /usr/bin/sudo /usr/bin/apt-get clean -y
else
    echo "ERROR: Package update/upgrade failed."
fi

# 3. Verify UniFi service health
echo "[3/4] Checking UniFi service status..."
/usr/bin/sleep 15

# Checks if the UniFi 'service' (the background program) is running correctly.
if /usr/bin/systemctl is-active --quiet unifi; then
    echo "SUCCESS: UniFi service is active and running."
else
    echo "WARNING: UniFi service is not active. Attempting restart..."
    /usr/bin/sudo /usr/bin/systemctl restart unifi
    /usr/bin/sleep 10
    if /usr/bin/systemctl is-active --quiet unifi; then
        echo "SUCCESS: UniFi service restarted successfully."
    else
        echo "ERROR: UniFi service failed to start. Manual intervention needed."
    fi
fi

# 4. Check for reboot requirement
echo "[4/4] Checking for reboot requirement..."
# Ubuntu creates a specific file if a security update (like a Kernel update) 
# needs a reboot to take effect.
if [ -f /var/run/reboot-required ]; then
    REASON=$(/usr/bin/cat /var/run/reboot-required.pkgs 2>/dev/null | /usr/bin/sed 's/^/ due to: /' || echo "")
    echo "REBOOT REQUIRED$REASON"
    echo "=========================================================="
    echo "MAINTENANCE COMPLETE (REBOOTING): $(/usr/bin/date +"%Y-%m-%d %H:%M:%S")"
    echo ""
    # Waits 30 seconds to allow logs to finish writing before restarting the server.
    /usr/bin/sleep 30
    /usr/bin/sudo /usr/sbin/reboot
else
    echo "No reboot required."
    echo "=========================================================="
    echo "MAINTENANCE COMPLETE: $(/usr/bin/date +"%Y-%m-%d %H:%M:%S")"
    echo ""
fi
