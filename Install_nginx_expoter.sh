#!/bin/bash

# NGINX exporter version
NGINX_EXPORTER_VERSION="0.9.0"

# NGINX exporter binary download URL
NGINX_EXPORTER_URL="https://github.com/nginxinc/nginx-prometheus-exporter/releases/download/v${NGINX_EXPORTER_VERSION}/nginx-prometheus-exporter-${NGINX_EXPORTER_VERSION}-linux-amd64.tar.gz"

# NGINX exporter configuration
NGINX_EXPORTER_CONFIG="/etc/nginx-exporter/nginx-exporter.conf"
NGINX_STATUS_ENDPOINT="http://localhost/nginx_status"

# NGINX configuration file
NGINX_CONF="/etc/nginx/nginx.conf"

# Install required packages
sudo apt-get update
sudo apt-get install -y wget tar

# Download and install NGINX exporter binary
wget "${NGINX_EXPORTER_URL}"
tar -xzvf "nginx-prometheus-exporter-${NGINX_EXPORTER_VERSION}-linux-amd64.tar.gz"
sudo mv nginx-prometheus-exporter /usr/local/bin/

# Create NGINX exporter configuration file
echo "nginx" | sudo tee "${NGINX_EXPORTER_CONFIG}"
echo "nginx.scrape_uri: ${NGINX_STATUS_ENDPOINT}" | sudo tee -a "${NGINX_EXPORTER_CONFIG}"

# Enable NGINX status module in NGINX configuration
sudo sed -i '/^#.*stub_status/s/^#//' "${NGINX_CONF}"
sudo sed -i 's/localhost/127.0.0.1/g' "${NGINX_CONF}"

# Restart NGINX
sudo service nginx restart

# Run NGINX exporter
sudo nohup nginx-prometheus-exporter -nginx.scrape-uri="${NGINX_STATUS_ENDPOINT}" -config.file="${NGINX_EXPORTER_CONFIG}" > /dev/null 2>&1 &

echo "NGINX exporter installation and configuration completed."
