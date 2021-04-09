#!/bin/sh
server_name="${proxy_server}"
sudo hostnamectl set-hostname $server_name --static
#sudo yum update -y
sudo amazon-linux-extras install nginx1 -y
sudo rm -f /etc/nginx/nginx.conf
sudo cat > /etc/nginx/nginx.conf <<EOF
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;
include /usr/share/nginx/modules/*.conf;
events {
    worker_connections 1024;
}
http {
    server {
        listen       80;
        listen       [::]:80;
        server_name  _;
        location /prometheus/ {
        proxy_pass http://${prom_server}:9090;
        }
        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;
        error_page 404 /404.html;
            location = /40x.html {
        }

        error_page 500 502 503 504 /50x.html;
            location = /50x.html {
        }
    }
}
EOF
sudo systemctl enable nginx.service
sudo systemctl start nginx.service
sudo useradd --no-create-home node_exporter
wget https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-amd64.tar.gz
tar xzf node_exporter-1.0.1.linux-amd64.tar.gz
sudo cp node_exporter-1.0.1.linux-amd64/node_exporter /usr/local/bin/node_exporter
rm -rf node_exporter-1.0.1.linux-amd64.tar.gz node_exporter-1.0.1.linux-amd64
sudo cat > /etc/systemd/system/node-exporter.service <<EOF
[Unit]
Description=Prometheus Node Exporter Service
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable node-exporter
sudo systemctl start node-exporter