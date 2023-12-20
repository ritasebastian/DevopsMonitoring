#!/bin/bash

# Set variables
EXPORTER_VERSION="0.15.0"
EXPORTER_URL="https://github.com/prometheus-community/postgres_exporter/releases/download/v${EXPORTER_VERSION}/postgres_exporter-${EXPORTER_VERSION}.linux-amd64.tar.gz"
EXPORTER_BINARY="postgres_exporter-${EXPORTER_VERSION}.linux-amd64.tar.gz"
EXPORTER_USER="postgres_exporter"
EXPORTER_SERVICE_FILE="/etc/systemd/system/postgres_exporter.service"
EXPORTER_CONFIG_FILE="/etc/postgres_exporter/postgres_exporter.yml"

# Add a dedicated user for PostgreSQL Exporter
sudo useradd --no-create-home --shell /bin/false $EXPORTER_USER

# Download and extract PostgreSQL Exporter
wget $EXPORTER_URL
tar xvfz $EXPORTER_BINARY

# Move the binary to /usr/local/bin
sudo mv postgres_exporter-${EXPORTER_VERSION}.linux-amd64/postgres_exporter /usr/local/bin/

# Create directory for the configuration file
sudo mkdir -p /etc/postgres_exporter

# Create your PostgreSQL Exporter configuration file (replace this with your actual configuration)
sudo tee $EXPORTER_CONFIG_FILE > /dev/null <<EOF
# Your PostgreSQL Exporter configuration goes here
# Example:
# postgresql://username:password@hostname:port/database
DATA_SOURCE_NAME: "postgresql://your_postgres_user:your_postgres_password@your_postgres_host:your_postgres_port/your_database?sslmode=disable"
EOF

# Clean up downloaded files
rm -rf $EXPORTER_BINARY postgres_exporter-${EXPORTER_VERSION}.linux-amd64

# Create systemd service file
sudo tee $EXPORTER_SERVICE_FILE > /dev/null <<EOF
[Unit]
Description=PostgreSQL Exporter
After=network.target

[Service]
User=$EXPORTER_USER
ExecStart=/usr/local/bin/postgres_exporter --web.listen-address=":9187" --web.telemetry-path="/metrics" --log.level="info" --extend.query-path="/path/to/queries.yml" --config.file=$EXPORTER_CONFIG_FILE

[Install]
WantedBy=default.target
EOF

# Reload systemd and start PostgreSQL Exporter
sudo systemctl daemon-reload
sudo systemctl start postgres_exporter
sudo systemctl enable postgres_exporter

echo "User $EXPORTER_USER added. PostgreSQL Exporter version ${EXPORTER_VERSION} has been installed and configured as a service."
echo "Verify metrics at http://your_instance_ip:9187/metrics."
