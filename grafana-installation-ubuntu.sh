#!/bin/bash

# Exit on error
set -e

#---------------------------------------------
# Ensure script is run as root
#---------------------------------------------
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script with sudo or as root. Exiting."
  exit 1
fi

#---------------------------------------------
# Variables
#---------------------------------------------
grafana_repo_url="https://packages.grafana.com/oss/deb"
grafana_gpg_key_url="https://packages.grafana.com/gpg.key"

#---------------------------------------------
# Add Grafana APT repository
#---------------------------------------------
echo "Installing prerequisites..."
apt-get update
apt-get install -y apt-transport-https software-properties-common wget gnupg

echo "Adding Grafana GPG key..."
wget -q -O - "$grafana_gpg_key_url" | apt-key add -

echo "Adding Grafana repository..."
add-apt-repository "deb $grafana_repo_url stable main"

#---------------------------------------------
# Install Grafana
#---------------------------------------------
echo "Updating package lists..."
apt-get update

echo "Installing Grafana..."
apt-get install -y grafana

#---------------------------------------------
# Enable and start Grafana service
#---------------------------------------------
echo "Enabling and starting Grafana service..."
systemctl enable grafana-server --now

#---------------------------------------------
# Completion message
#---------------------------------------------
echo -e "\nGrafana installation complete!"
echo "Access Grafana at http://<your-server-ip>:3000 (default user/pass: admin/admin)"
