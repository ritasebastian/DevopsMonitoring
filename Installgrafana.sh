#!/bin/bash

GRAFANA_VERSION="8.0.0"
GRAFANA_RPM="grafana-${GRAFANA_VERSION}-1.x86_64.rpm"
GRAFANA_URL="https://dl.grafana.com/oss/release/${GRAFANA_RPM}"

GRAFANA_USER="grafana"
GRAFANA_HOME="/home/${GRAFANA_USER}"

# Step 1: Create Grafana user
sudo useradd -m -s /bin/bash ${GRAFANA_USER}

# Step 2: Download and Install Grafana
sudo yum install -y ${GRAFANA_URL}

# Step 3: Configure Grafana as a Service
sudo systemctl start grafana-server
sudo systemctl enable grafana-server

# Step 4: Create a systemd service unit file
cat > /etc/systemd/system/grafana.service <<EOL
[Unit]
Description=Grafana Server
After=network.target

[Service]
ExecStart=/usr/sbin/grafana-server --config=/etc/grafana/grafana.ini --pidfile=/var/run/grafana/grafana-server.pid
Restart=always
User=${GRAFANA_USER}
WorkingDirectory=${GRAFANA_HOME}

[Install]
WantedBy=default.target
EOL

# Step 5: Start and Enable the Grafana service
sudo systemctl daemon-reload
sudo systemctl restart grafana-server
sudo systemctl enable grafana-server

echo "Grafana is now running. Access the web UI at http://localhost:3000"
