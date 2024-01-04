#!/bin/bash

# Define mysqld_exporter version
EXPORTER_VERSION="0.13.0"

# Download and install mysqld_exporter
wget "https://github.com/prometheus/mysqld_exporter/releases/download/v${EXPORTER_VERSION}/mysqld_exporter-${EXPORTER_VERSION}.linux-amd64.tar.gz"
tar xvfz "mysqld_exporter-${EXPORTER_VERSION}.linux-amd64.tar.gz"
sudo mv "mysqld_exporter-${EXPORTER_VERSION}.linux-amd64/mysqld_exporter" /usr/local/bin/

# Create user for mysqld_exporter
sudo useradd -M -r -s /bin/false mysqld_exporter

# Set ownership and permissions
sudo chown mysqld_exporter:mysqld_exporter /usr/local/bin/mysqld_exporter

# Create systemd service file
cat <<EOF | sudo tee /etc/systemd/system/mysqld_exporter.service
[Unit]
Description=Prometheus MySQL Exporter
After=network.target

[Service]
User=mysqld_exporter
Group=mysqld_exporter
Type=simple
ExecStart=/usr/local/bin/mysqld_exporter

[Install]
WantedBy=default.target
EOF

# Reload systemd and start mysqld_exporter
sudo systemctl daemon-reload
sudo systemctl start mysqld_exporter
sudo systemctl enable mysqld_exporter

# Allow mysqld_exporter through the firewall
sudo firewall-cmd --zone=public --add-port=9104/tcp --permanent
sudo firewall-cmd --reload

# Display status
sudo systemctl status mysqld_exporter
