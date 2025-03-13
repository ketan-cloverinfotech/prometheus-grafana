#!/bin/bash

# Variables
PROM_VERSION="2.52.0"
KUBE_API="https://192.168.164.137:6443"
BEARER_TOKEN="<REPLACE_WITH_YOUR_TOKEN>"

# Download and install Prometheus
cd /tmp
sudo rm -rf prometheus-${PROM_VERSION}.linux-amd64*
wget https://github.com/prometheus/prometheus/releases/download/v${PROM_VERSION}/prometheus-${PROM_VERSION}.linux-amd64.tar.gz
tar -xzf prometheus-${PROM_VERSION}.linux-amd64.tar.gz

# Move binaries
sudo mv prometheus-${PROM_VERSION}.linux-amd64/prometheus /usr/local/bin/
sudo mv prometheus-${PROM_VERSION}.linux-amd64/promtool /usr/local/bin/
sudo mkdir -p /etc/prometheus
sudo mv prometheus-${PROM_VERSION}.linux-amd64/{consoles,console_libraries} /etc/prometheus

# Create Prometheus user and directories
sudo useradd -M -r -s /bin/false prometheus
sudo mkdir -p /var/lib/prometheus
sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus
sudo chown prometheus:prometheus /usr/local/bin/prometheus

# Create Prometheus configuration
sudo bash -c "cat > /etc/prometheus/prometheus.yml" <<EOF
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "kubernetes-nodes"
    kubernetes_sd_configs:
      - role: node
        api_server: "${KUBE_API}"
    bearer_token: "${BEARER_TOKEN}"
    tls_config:
      insecure_skip_verify: true
EOF

# Create systemd service for Prometheus
sudo bash -c "cat > /etc/systemd/system/prometheus.service" <<EOF
[Unit]
Description=Prometheus Monitoring
After=network.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \\
  --config.file=/etc/prometheus/prometheus.yml \\
  --storage.tsdb.path=/var/lib/prometheus/ \\
  --web.console.templates=/etc/prometheus/consoles \\
  --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd, start and enable Prometheus
sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl restart prometheus

# Check status
sudo systemctl status prometheus --no-pager
