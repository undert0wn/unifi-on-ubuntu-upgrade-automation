# UniFi Network Application: Automated Maintenance

A robust Bash script designed for Ubuntu-based UniFi controllers. It automates monthly system updates and UniFi Network Application upgrades while bypassing interactive prompts and ensuring service health.

## 🚀 Features
* **Zero-Interaction Updates:** Pre-seeds `debconf` to bypass the UniFi "backup confirmation" prompt.
* **Config Protection:** Ensures existing UniFi configurations are never overwritten by package defaults.
* **Version Tracking:** Logs the exact version of UniFi before and after the update.
* **Service Recovery:** Automatically verifies if the UniFi service is running after an update.
* **Smart Reboots:** Only triggers a system reboot if required by the OS (e.g., kernel updates).
* **Clean Logs:** Compatible with `logrotate` for long-term history without disk bloat.

---

## 🛠️ Installation

### 1. Download the script
Create the file on your server:
```bash
nano maintain.sh


Copy and paste the full content of the maintain.sh file from this repository into the editor.Save and exit by pressing Ctrl+O, Enter, and then Ctrl+X.2. Set Execute Permissions (Required)Linux requires you to explicitly grant "execute" permissions to a script before it can run:bash

chmod +x ~/maintain.sh

3. Test the Script Manually (Highly Recommended)Before scheduling automation, run the script once manually to confirm everything works correctly on your system:bash

~/maintain.sh

Check the terminal output and review the new log file at ~/maintenance.log.4. Schedule the Automation (Cron) (Recommended)To ensure your server stays updated without manual intervention, schedule the script to run on the first Sunday of every month at 3:00 AM:bash

sudo crontab -e

Scroll to the bottom of the file and add this line (replace YOUR_USERNAME with your actual Linux username, e.g., ize):cron

0 3 * * Sun [ "$(/usr/bin/date +\%d)" -le 7 ] && /home/YOUR_USERNAME/maintain.sh

Example (for username ize):cron

0 3 * * Sun [ "$(/usr/bin/date +\%d)" -le 7 ] && /home/ize/maintain.sh

Save and exit the editor.How it works: The cron entry fires every Sunday at 3 AM, but the condition [ ... -le 7 ] ensures it only executes when the day of the month is 7 or earlier — guaranteeing exactly one run per month on the first Sunday. Log Management & History (Optional but Recommended)The script records every action to a file named maintenance.log in your home directory.To keep this file organized and prevent it from using too much disk space, use logrotate to maintain a rolling 12-month history.Create the rotation config:bash

sudo nano /etc/logrotate.d/unifi-maintenance

Paste the following (update YOUR_USERNAME to match your home path):

/home/YOUR_USERNAME/maintenance.log {
    monthly
    rotate 12
    compress
    delaycompress
    missingok
    notifempty
    copytruncate
}

Example (for username ize):

/home/ize/maintenance.log {
    monthly
    rotate 12
    compress
    delaycompress
    missingok
    notifempty
    copytruncate
}

Save and exit. Logrotate runs automatically via the system's daily cron jobs — no further action needed.You can view the current log at any time with:bash

tail -n 100 ~/maintenance.log

 Understanding the Script Logic (For New Linux Users)Here is a brief breakdown of what the script does:Non-Interactive Mode: Sets DEBIAN_FRONTEND=noninteractive to prevent any pop-ups or prompts during package installation/upgrades.
Pre-seeding: Automatically answers "true" to the UniFi backup confirmation prompt by injecting the answer into the package manager database.
Force-Confold: Uses the --force-confold flag to keep your existing configuration files instead of overwriting them with new defaults.
Health Wait: Includes a 15-second pause after updates to give the UniFi database time to settle before checking service status.
Smart Service Check: Verifies the unifi service is active and restarts it if necessary.

 DisclaimerThis script is intended only for controllers installed directly on Ubuntu (not Docker-based installations).Always ensure you have remote backups enabled in your UniFi Cloud portal before running automated updates.Major UniFi version jumps (e.g., those changing MongoDB versions) may still require manual intervention — this script handles standard incremental updates smoothly.Test the script on a non-production controller first if possible.Enjoy a hands-off, always-up-to-date UniFi controller! 

