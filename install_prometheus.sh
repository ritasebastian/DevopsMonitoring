#!/bin/bash

PROMETHEUS_VERSION="2.49.0-rc.0"
PROMETHEUS_TAR="prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz"
PROMETHEUS_URL="https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/${PROMETHEUS_TAR}"

PROMETHEUS_USER="prometheus"
PROMETHEUS_HOME="/home/${PROMETHEUS_USER}"
PROMETHEUS_INSTALL_DIR="${PROMETHEUS_HOME}/prometheus-${PROMETHEUS_VERSION}.linux-amd64"

# Step 1: Create Prometheus user
sudo useradd -m -s /bin/bash ${PROMETHEUS_USER}

# Step 2: Download and Extract Prometheus
wget ${PROMETHEUS_URL}
tar xvfz ${PROMETHEUS_TAR}
sudo mv "prometheus-${PROMETHEUS_VERSION}.linux-amd64" ${PROMETHEUS_INSTALL_DIR}
sudo chown -R ${PROMETHEUS_USER}:${PROMETHEUS_USER} ${PROMETHEUS_HOME}

# Step 3: Create Prometheus Configuration
cat > ${PROMETHEUS_HOME}/prometheus.yml <<EOL
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
EOL

# Step 4: Create a systemd service unit file
cat > /etc/systemd/system/prometheus.service <<EOL
[Unit]
Description=Prometheus Server
After=network.target

[Service]
ExecStart=${PROMETHEUS_INSTALL_DIR}/prometheus --config.file=${PROMETHEUS_HOME}/prometheus.yml
Restart=always
User=${PROMETHEUS_USER}
WorkingDirectory=${PROMETHEUS_HOME}

[Install]
WantedBy=default.target
EOL

# Step 5: Start and Enable the Prometheus service
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus

echo "Prometheus is now running. Access the web UI at http://localhost:9090"
