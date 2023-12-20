#!/bin/bash

# Variables
EXPORTER_VERSION="0.10.0"
EXPORTER_TAR="postgres_exporter_v${EXPORTER_VERSION}_linux-amd64.tar.gz"
EXPORTER_URL="https://github.com/wrouesnel/postgres_exporter/releases/download/v${EXPORTER_VERSION}/${EXPORTER_TAR}"
EXPORTER_BIN="/usr/local/bin/postgres_exporter"
EXPORTER_SERVICE="/etc/systemd/system/postgres_exporter.service"
EXPORTER_CONFIG="/etc/postgres_exporter.yml"
POSTGRES_USER="postgres"
POSTGRES_PASSWORD="password"
EXPORTER_PORT="9187"

# Install required tools
# sudo yum install -y wget tar
# Create a PostgreSQL user for the exporter
# psql -U postgres -c "CREATE USER $POSTGRES_USER WITH PASSWORD '$POSTGRES_PASSWORD';"
# psql -U postgres -c "ALTER USER $POSTGRES_USER WITH SUPERUSER;"

# Download and extract PostgreSQL Node Exporter
wget "$EXPORTER_URL"
tar xvfz "$EXPORTER_TAR"
sudo mv "postgres_exporter_v${EXPORTER_VERSION}_linux-amd64/postgres_exporter" "$EXPORTER_BIN"
rm -rf "postgres_exporter_v${EXPORTER_VERSION}_linux-amd64" "$EXPORTER_TAR"

# Create configuration file
echo "data_source_name: \"postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@localhost:5432/?sslmode=disable\"" | sudo tee "$EXPORTER_CONFIG"

# Create systemd service
echo "[Unit]
Description=PostgreSQL Node Exporter
After=network.target

[Service]
ExecStart=$EXPORTER_BIN --config.file=$EXPORTER_CONFIG
Restart=always
User=$POSTGRES_USER
LimitNOFILE=infinity

[Install]
WantedBy=default.target" | sudo tee "$EXPORTER_SERVICE"

# Start and enable the service
sudo systemctl start postgres_exporter
sudo systemctl enable postgres_exporter
sudo systemctl status postgres_exporter

# Open firewall port for PostgreSQL Node Exporter
# sudo firewall-cmd --zone=public --add-port=$EXPORTER_PORT/tcp --permanent
# sudo firewall-cmd --reload

# Clean up
# rm -f install_postgres_exporter.sh
