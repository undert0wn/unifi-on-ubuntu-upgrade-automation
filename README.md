UniFi Network Application: Automated Maintenance Script
A robust Bash script designed for Ubuntu-based UniFi controllers. It automates the monthly system updates and UniFi Network Application upgrades while bypassing interactive prompts and ensuring service health.

🚀 Features
     -Zero-Interaction Updates: Pre-seeds debconf to bypass the UniFi backup confirmation prompt.
     -Config Protection: Uses force-confold to ensure your existing UniFi configurations are never overwritten by package defaults.
     -Version Tracking: Logs the exact version of UniFi before and after the update process.
     -Service Recovery: Automatically verifies if the UniFi service is running after an update and attempts a restart if it's down.
     -Smart Reboots: Only triggers a system reboot if required by the OS (e.g., kernel updates).
     -Clean Logs: Compatible with logrotate for long-term history without disk bloat.

📋 Prerequisites
     -Ubuntu 20.04/22.04/24.04.
     -UniFi Network Application installed via the official Ubiquiti Debian repository.
     -A user with sudo privileges.

🛠️ Installation
1. Download the script
Clone this repository or create the file manually:

Bash

nano maintain.sh
(Paste the contents of maintain.sh from this repo)

2. Set Permissions
Make the script executable:

Bash

chmod +x maintain.sh
3. Schedule the Automation
To run the maintenance automatically on the first Sunday of every month at 3:00 AM, add it to your root crontab:

Bash

sudo crontab -e
Add the following line to the bottom:

Code snippet

# Run UniFi maintenance at 3:00 AM on the first Sunday of every month
0 3 * * Sun [ "$(/usr/bin/date +\%d) -le 7 ] && /path/to/your/maintain.sh
📈 Log Management
The script logs all activity to ~/maintenance.log. To prevent this file from growing indefinitely, it is recommended to set up logrotate.

Create a rotation config:

Bash

sudo nano /etc/logrotate.d/unifi-maintenance
Paste the following (adjust the path to match your home directory):

Plaintext

/home/YOUR_USERNAME/maintenance.log {
    monthly
    rotate 12
    compress
    delaycompress
    missingok
    notifempty
    copytruncate
}
🔍 How it Works
Step 1: Injects the has_backup boolean into the debconf database to satisfy the UniFi installer.

Step 2: Runs apt-get update and full-upgrade. It captures the UniFi version using dpkg and awk to report changes.

Step 3: Pauses for 15 seconds to allow the database to initialize, then checks systemctl is-active.

Step 4: Checks for the existence of /var/run/reboot-required. If present, it logs the reason and reboots the system after a 30-second warning.

⚠️ Disclaimer
Always ensure you have a remote backup of your UniFi configuration (Settings > OS Settings > Console Settings > Auto Backup) before running automated updates.
