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
