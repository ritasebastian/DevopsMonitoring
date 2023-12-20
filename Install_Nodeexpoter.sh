#!/bin/bash

NODE_EXPORTER_VERSION="1.2.2"
NODE_EXPORTER_TAR="node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz"
NODE_EXPORTER_URL="https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/${NODE_EXPORTER_TAR}"

NODE_EXPORTER_USER="node_exporter"
NODE_EXPORTER_HOME="/home/${NODE_EXPORTER_USER}"
NODE_EXPORTER_INSTALL_DIR="${NODE_EXPORTER_HOME}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64"

# Create Node Exporter user
sudo useradd -m -s /bin/bash ${NODE_EXPORTER_USER}

# Download and Extract Node Exporter
wget ${NODE_EXPORTER_URL}
tar xvfz ${NODE_EXPORTER_TAR}
sudo mv "node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64" ${NODE_EXPORTER_INSTALL_DIR}
sudo chown -R ${NODE_EXPORTER_USER}:${NODE_EXPORTER_USER} ${NODE_EXPORTER_HOME}

# Create a systemd service unit file for Node Exporter
cat > /etc/systemd/system/node_exporter.service <<EOL
[Unit]
Description=Node Exporter
After=network.target

[Service]
ExecStart=${NODE_EXPORTER_INSTALL_DIR}/node_exporter
Restart=always
User=${NODE_EXPORTER_USER}
WorkingDirectory=${NODE_EXPORTER_HOME}

[Install]
WantedBy=default.target
EOL

# Start and Enable the Node Exporter service
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter
