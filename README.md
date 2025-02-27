# 🛡️ Knockd Persistence / System Disruption  🛡️

This script automates the installation, configuration, and hiding of the `knockd` service, which allows you to control system services (e.g., start/stop) using **port knocking**. This can also be modified to create persistence techniques. It is designed for **Red Team** activities, where stealth and controlled access to systems are critical.

---

## 🚀 **Features**
- Installs and configures `knockd` automatically.
- Allows you to define a custom service to control (e.g., `apache2`, `docker.service`, etc.).
- Hides the `knockd` systemd service by renaming it to `.kernel-loop.service`.
- Binds the `knockd` process to `/var/empty` for added stealth.

---

## 🎯 **What is Port Knocking?**
Port knocking is a stealthy method of controlling access to a system or service. It works by requiring a specific sequence of connection attempts (knocks) to closed ports before a service is activated or deactivated. For example:
- A sequence like `7000, 8000, 9000` could be used to **stop** a service.
- A sequence like `1111, 2222, 3333` could be used to **start** a service.

This technique is modified to be used in **Red Team** operations to:
- Hide services from unauthorized users.
- Provide a covert way to enable or disable critical services.
- Avoid detection by network monitoring tools.

---

## 🛠️ **Prerequisites**
- A Linux-based system (tested on VMs).
- Root access (the script must be run as root).
- `apt` package manager (for Debian/Ubuntu-based systems).

---

## 📜 **How It Works**
1. **Install `knockd`**: The script installs `knockd` using `apt`.
2. **Configure `knockd.conf`**: It creates a custom `knockd.conf` file to define port sequences for starting and stopping a specified service.
3. **Hide the `knockd` Service**: The script renames the `knockd` service file to `.kernel-loop.service` to make it less visible.
4. **Bind Mount `/proc/<PID>`**: It captures the PID of the `knockd` process and binds it to `/var/empty` to obscure it further.

---

## 🖥️ **Usage**
1. Clone this repository or download the script.
2. Make the script executable:
   ```bash
   chmod +x knockd_manager.sh
3. Commands if script failed to purge and restart:
   ```bash
   rm -rf /usr/lib/system/system/.kernel-loop.service
   sudo systemctl stop knockd 
   sudo systemctl disable knockd
   sudo apt remove --purge knockd -y
 


