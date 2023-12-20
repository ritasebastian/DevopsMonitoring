#!/bin/bash

ALERTMANAGER_VERSION="0.23.0"
ALERTMANAGER_TAR="alertmanager-${ALERTMANAGER_VERSION}.linux-amd64.tar.gz"
ALERTMANAGER_URL="https://github.com/prometheus/alertmanager/releases/download/v${ALERTMANAGER_VERSION}/${ALERTMANAGER_TAR}"

ALERTMANAGER_USER="alertmanager"
ALERTMANAGER_HOME="/home/${ALERTMANAGER_USER}"
ALERTMANAGER_INSTALL_DIR="${ALERTMANAGER_HOME}/alertmanager-${ALERTMANAGER_VERSION}.linux-amd64"

# Create Alertmanager user
sudo useradd -m -s /bin/bash ${ALERTMANAGER_USER}

# Download and Extract Alertmanager
wget ${ALERTMANAGER_URL}
tar xvfz ${ALERTMANAGER_TAR}
sudo mv "alertmanager-${ALERTMANAGER_VERSION}.linux-amd64" ${ALERTMANAGER_INSTALL_DIR}
sudo chown -R ${ALERTMANAGER_USER}:${ALERTMANAGER_USER} ${ALERTMANAGER_HOME}

# Create Alertmanager Configuration
cat > ${ALERTMANAGER_HOME}/alertmanager.yml <<EOL
global:
  resolve_timeout: 5m

route:
  group_by: [Alertname]
  receiver: email-me

receivers:
- name: email-me
  email_configs:
  - to: your-email@example.com
    from: alertmanager@example.com
    smarthost: smtp.example.com:587
    auth_username: "your-username"
    auth_password: "your-password"
    send_resolved: true
EOL

# Create a systemd service unit file for Alertmanager
cat > /etc/systemd/system/alertmanager.service <<EOL
[Unit]
Description=Alertmanager
After=network.target

[Service]
ExecStart=${ALERTMANAGER_INSTALL_DIR}/alertmanager --config.file=${ALERTMANAGER_HOME}/alertmanager.yml
Restart=always
User=${ALERTMANAGER_USER}
WorkingDirectory=${ALERTMANAGER_HOME}

[Install]
WantedBy=default.target
EOL

# Start and Enable the Alertmanager service
sudo systemctl daemon-reload
sudo systemctl start alertmanager
sudo systemctl enable alertmanager
