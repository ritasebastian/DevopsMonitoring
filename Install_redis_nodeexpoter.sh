#!/bin/bash

# Redis exporter version
REDIS_EXPORTER_VERSION="1.17.0"

# Redis exporter binary download URL
REDIS_EXPORTER_URL="https://github.com/oliver006/redis_exporter/releases/download/v${REDIS_EXPORTER_VERSION}/redis_exporter-${REDIS_EXPORTER_VERSION}.linux-amd64.tar.gz"

# Prometheus node exporter configuration file
PROMETHEUS_CONFIG="/etc/prometheus/prometheus.yml"

# Install required packages
sudo yum install -y wget tar

# Download and install Redis exporter binary
wget "${REDIS_EXPORTER_URL}"
tar -xzvf "redis_exporter-${REDIS_EXPORTER_VERSION}.linux-amd64.tar.gz"
sudo mv redis_exporter-${REDIS_EXPORTER_VERSION}.linux-amd64/redis_exporter /usr/local/bin/

# Create Prometheus configuration for Redis exporter
echo "  - job_name: 'redis_exporter'" | sudo tee -a "${PROMETHEUS_CONFIG}"
echo "    static_configs:" | sudo tee -a "${PROMETHEUS_CONFIG}"
echo "    - targets: ['localhost:9121']" | sudo tee -a "${PROMETHEUS_CONFIG}"

# Run Redis exporter
sudo nohup redis_exporter > /dev/null 2>&1 &

echo "Redis exporter installation and configuration completed."
