#!/bin/bash

set -e

#---------------------------------------------
# Ensure script is run as root
#---------------------------------------------
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root or with sudo. Exiting."
  exit 1
fi

#---------------------------------------------
# Variables
#---------------------------------------------
PROM_TAG=$(curl -s https://api.github.com/repos/prometheus/prometheus/releases/latest \
  | grep -m1 '"tag_name":' \
  | sed -E 's/.*"tag_name": *"([^\"]+)".*/\1/')
PROM_VERSION=${PROM_TAG#v}
USER=prometheus
CONFIG_DIR=/etc/prometheus
DATA_DIR=/var/lib/prometheus

#---------------------------------------------
# Create prometheus user and directories
#---------------------------------------------
id "$USER" &>/dev/null || useradd --no-create-home --shell /usr/sbin/nologin "$USER"
mkdir -p "$CONFIG_DIR" "$DATA_DIR"

#---------------------------------------------
# Download and extract Prometheus
#---------------------------------------------
echo "Downloading Prometheus $PROM_TAG..."
cd /tmp
curl -sL "https://github.com/prometheus/prometheus/releases/download/$PROM_TAG/prometheus-$PROM_VERSION.linux-amd64.tar.gz" \
  -o prometheus-$PROM_VERSION.linux-amd64.tar.gz

tar xzf prometheus-$PROM_VERSION.linux-amd64.tar.gz

#---------------------------------------------
# Install binaries
#---------------------------------------------
cd prometheus-$PROM_VERSION.linux-amd64
cp prometheus promtool /usr/local/bin/
chown "$USER":"$USER" /usr/local/bin/prometheus /usr/local/bin/promtool

#---------------------------------------------
# Copy configuration and console files
#---------------------------------------------
cp prometheus.yml "$CONFIG_DIR/"
if [ -d consoles ]; then cp -r consoles "$CONFIG_DIR/"; fi
if [ -d console_libraries ]; then cp -r console_libraries "$CONFIG_DIR/"; fi
chown -R "$USER":"$USER" "$CONFIG_DIR" "$DATA_DIR"

#---------------------------------------------
# Create systemd service for Prometheus
#---------------------------------------------
cat << EOF > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus Monitoring Service
Wants=network-online.target
After=network-online.target

[Service]
User=$USER
Group=$USER
Type=simple
ExecStart=/usr/local/bin/prometheus \
  --config.file=$CONFIG_DIR/prometheus.yml \
  --storage.tsdb.path=$DATA_DIR \
  --web.listen-address=0.0.0.0:9090
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

#---------------------------------------------
# Enable and start Prometheus
#---------------------------------------------
systemctl daemon-reload
echo "Enabling and starting Prometheus..."
systemctl enable prometheus --now

#---------------------------------------------
# Completion message
#---------------------------------------------
echo -e "\nPrometheus installation complete!"
echo "Access Prometheus at http://<your-server-ip>:9090 (default port 9090)"
