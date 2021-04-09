#!/bin/bash
#Update and Install
servername="${prometheus_server}"
sudo echo "127.0.0.1   "$servername >> /etc/hosts
sudo hostnamectl set-hostname $servername --static
sudo yum update -y
sudo yum install wget -y
sudo useradd --no-create-home svc-prom
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus
wget https://github.com/prometheus/prometheus/releases/download/v2.19.0/prometheus-2.19.0.linux-amd64.tar.gz
tar xvfz prometheus-2.19.0.linux-amd64.tar.gz


#Setup folders
sudo cp prometheus-2.19.0.linux-amd64/prometheus /usr/local/bin
sudo cp prometheus-2.19.0.linux-amd64/promtool /usr/local/bin/
sudo cp -r prometheus-2.19.0.linux-amd64/consoles /etc/prometheus
sudo cp -r prometheus-2.19.0.linux-amd64/console_libraries /etc/prometheus

sudo cp prometheus-2.19.0.linux-amd64/promtool /usr/local/bin/
rm -rf prometheus-2.19.0.linux-amd64.tar.gz prometheus-2.19.0.linux-amd64

#Setup permissions
sudo chown svc-prom:svc-prom /etc/prometheus
sudo chown svc-prom:svc-prom /usr/local/bin/prometheus
sudo chown svc-prom:svc-prom /usr/local/bin/promtool
sudo chown -R svc-prom:svc-prom /etc/prometheus/consoles
sudo chown -R svc-prom:svc-prom /etc/prometheus/console_libraries
sudo chown -R svc-prom:svc-prom /var/lib/prometheus

#create default prometheus config file scraping itself
#Add additional server which is already running export_node process
cat > /etc/prometheus/prometheus.yml <<EOF
global:
  scrape_interval: 15s
  external_labels:
    monitor: 'prometheus'

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['$servername:9090']
    metrics_path: /prometheus/metrics
EOF

#setup service
cat > /etc/systemd/system/prometheus.service <<EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries \
    --web.external-url http://$servername:9090/prometheus/

[Install]
WantedBy=multi-user.target
EOF

#run service
sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl start prometheus.service

# end of script
