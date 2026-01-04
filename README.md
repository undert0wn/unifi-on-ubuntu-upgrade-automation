UniFi Network Application – Automated Maintenance Script

A robust Bash maintenance script for Ubuntu-based UniFi Network Application controllers.
It performs monthly system updates and UniFi upgrades with zero interaction, while protecting your configuration and verifying service health.

Features

Zero-interaction updates
Pre-seeds debconf to skip the UniFi backup confirmation prompt.

Configuration protection
Uses --force-confold so existing UniFi settings are never overwritten.

Version tracking
Logs the exact UniFi version before and after every upgrade.

Service recovery
Automatically restarts the UniFi service if it is not running after an update.

Smart reboots
Reboots only when the OS explicitly flags it (for example, kernel updates).

Clean logs
Compatible with logrotate for long-term history without disk bloat.

Prerequisites

Ubuntu 20.04 / 22.04 / 24.04

UniFi Network Application installed from the official Ubiquiti Debian repository

A user with sudo privileges

Installation
1. Download the script
nano maintain.sh


Paste the script contents, then save and exit.

2. Make it executable
chmod +x maintain.sh

3. Schedule automatic execution

Edit root’s crontab:

sudo crontab -e


Add the following line at the bottom:

0 3 * * Sun [ "$(/usr/bin/date +%d)" -le 7 ] && /home/YOURUSERNAME/maintain.sh


Replace YOURUSERNAME with your actual username.

This schedule runs the script once per month, on the first Sunday at 03:00.

Log Management

All activity is appended to:

~/maintenance.log


To keep logs tidy, configure logrotate:

sudo nano /etc/logrotate.d/unifi-maintenance


Paste (and adjust the path if needed):

/home/YOURUSERNAME/maintenance.log {
    monthly
    rotate 12
    compress
    delaycompress
    missingok
    notifempty
    copytruncate
}

How It Works

Injects has_backup=true into debconf to satisfy the UniFi installer.

Runs apt-get update && apt-get full-upgrade and captures the UniFi version using dpkg.

Waits 15 seconds for the database to settle.

Checks service health with systemctl is-active.

If /var/run/reboot-required exists:

Logs the reboot reason

Waits 30 seconds

Reboots the system

Disclaimer

Intended only for native Ubuntu installs
(not Docker, Podman, or other containerized environments)

Always enable UniFi Cloud backups as an extra safety net

Major UniFi releases that change MongoDB or other core components may still require manual intervention

This script is optimized for routine, incremental updates

Test thoroughly on a non-production system before using in production

Enjoy a hands-off, always-up-to-date UniFi controller!

##########################################################################
UniFi Network Application – Automated Maintenance Script

A robust Bash maintenance script for Ubuntu-based UniFi Network Application controllers.
It performs monthly system updates and UniFi upgrades with zero interaction, while protecting your configuration and verifying service health.

✨ Features

Zero-interaction updates
Pre-seeds debconf to bypass the UniFi backup confirmation prompt.

Configuration protection
Uses --force-confold to ensure existing UniFi settings are never overwritten.

Version tracking
Logs the exact UniFi version before and after every upgrade.

Service recovery
Automatically restarts the UniFi service if it is not running after an update.

Smart reboots
Reboots only when required (e.g., kernel updates).

Clean logging
Compatible with logrotate for long-term history without disk bloat.

📋 Prerequisites

Ubuntu 20.04, 22.04, or 24.04

UniFi Network Application installed from the official Ubiquiti Debian repository

A user with sudo privileges

🚀 Installation
1. Download the script
nano maintain.sh


Paste the script contents, then save and exit.

2. Make it executable
chmod +x maintain.sh

3. Schedule automatic execution

Edit root’s crontab:

sudo crontab -e


Add the following line at the bottom:

0 3 * * Sun [ "$(/usr/bin/date +%d)" -le 7 ] && /home/YOURUSERNAME/maintain.sh


🔧 Replace YOURUSERNAME with your actual username.

This runs the script once per month, on the first Sunday at 03:00.

🗂 Log Management

All activity is appended to:

~/maintenance.log


To keep logs tidy, configure logrotate:

sudo nano /etc/logrotate.d/unifi-maintenance


Paste (and adjust the path if needed):

/home/YOURUSERNAME/maintenance.log {
    monthly
    rotate 12
    compress
    delaycompress
    missingok
    notifempty
    copytruncate
}

⚙️ How It Works

Injects has_backup=true into debconf to satisfy the UniFi installer.

Runs:

apt-get update && apt-get full-upgrade


while capturing the UniFi version via dpkg.

Waits 15 seconds for the database to settle.

Verifies service health using:

systemctl is-active


If /var/run/reboot-required exists:

Logs the reason

Issues a 30-second warning

Reboots the system

⚠️ Disclaimer

Intended only for native Ubuntu installs
(❌ not Docker, Podman, or other containerized deployments)

Always enable UniFi Cloud backups as an additional safety net

Major UniFi releases that modify MongoDB or other core components may still require manual intervention

This script is designed for routine, incremental updates

Test thoroughly on a non-production system before using in production

✅ Result

Enjoy a hands-off, self-maintaining, and always up-to-date UniFi controller 🎉
