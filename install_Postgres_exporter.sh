#!/bin/bash

# Set variables
POSTGRES_EXPORTER_VERSION="0.11.0"
POSTGRES_EXPORTER_USER="postgres_exporter"
POSTGRES_EXPORTER_BINARY="postgres_exporter_v${POSTGRES_EXPORTER_VERSION}_linux-amd64"
POSTGRES_EXPORTER_DOWNLOAD_URL="https://github.com/wrouesnel/postgres_exporter/releases/download/v${POSTGRES_EXPORTER_VERSION}/${POSTGRES_EXPORTER_BINARY}.tar.gz"
POSTGRES_EXPORTER_SERVICE_FILE="/etc/systemd/system/postgres_exporter.service"

# Download and extract PostgreSQL Exporter
wget "$POSTGRES_EXPORTER_DOWNLOAD_URL"
tar xvfz "${POSTGRES_EXPORTER_BINARY}.tar.gz"
sudo mv "$POSTGRES_EXPORTER_BINARY/postgres_exporter" /usr/local/bin/

# Create dedicated user
sudo useradd --no-create-home --shell /bin/false "$POSTGRES_EXPORTER_USER"
sudo chown "$POSTGRES_EXPORTER_USER:$POSTGRES_EXPORTER_USER" /usr/local/bin/postgres_exporter

# Create systemd service file
sudo tee "$POSTGRES_EXPORTER_SERVICE_FILE" > /dev/null <<EOF
[Unit]
Description=PostgreSQL Exporter
After=network.target

[Service]
User=$POSTGRES_EXPORTER_USER
ExecStart=/usr/local/bin/postgres_exporter --web.listen-address=":9187" --web.telemetry-path="/metrics" --log.level="info" --postgres.user="your_postgres_user" --postgres.password="your_postgres_password" --postgres.host="your_postgres_host" --postgres.port="your_postgres_port" --extend.query-path="/path/to/queries.yml"

[Install]
WantedBy=default.target
EOF

# Reload systemd and start PostgreSQL Exporter
sudo systemctl daemon-reload
sudo systemctl start postgres_exporter
sudo systemctl enable postgres_exporter
sudo systemctl status postgres_exporter

# Clean up
# rm -rf "${POSTGRES_EXPORTER_BINARY}.tar.gz" "$POSTGRES_EXPORTER_BINARY"

echo "PostgreSQL Exporter has been installed and configured. Verify metrics at http://your_instance_ip:9187/metrics."
