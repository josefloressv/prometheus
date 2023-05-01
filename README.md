# Prometheus
https://prometheus.io/

## Installation
https://prometheus.io/download/

``` bash
wget https://github.com/prometheus/prometheus/releases/download/v2.44.0-rc.0/prometheus-2.44.0-rc.0.linux-amd64.tar.gz
tar -xvf prometheus-2.44.0-rc.0.linux-amd64.tar.gz
rm prometheus-2.44.0-rc.0.linux-amd64.tar.gz
cd prometheus-2.44.0-rc.0.linux-amd64
./prometheus
```

### Install in Systemd
```bash
sudo useradd --no-create-home --shell /bin/false prometheus
sudo mkdir /etc/prometheus /var/lib/prometheus
sudo chown prometheus:prometheus /etc/prometheus /var/lib/prometheus

cd prometheus-2.44.0-rc.0.linux-amd64/
sudo cp prometheus promtool /usr/local/bin/
sudo chown prometheus:prometheus /usr/local/bin/prometheus /usr/local/bin/promtool

sudo cp -r prometheus.yml consoles/ console_libraries/  /etc/prometheus/
sudo chown -R prometheus:prometheus /etc/prometheus/

```

Creating the service
```bash
sudo vi /etc/systemd/system/prometheus.service
```
```bash
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
--config.file /etc/prometheus/prometheus.yml \
--storage.tsdb.path /var/lib/prometheus/ \
--web.console.templates=/etc/prometheus/consoles \
--web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target

```

```bash
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus
sudo systemctl status prometheus

```

### Test
Go to http://3.80.227.191:9090/
Search for expressions: up
or http://3.80.227.191:9090/metrics

## Node Export Installation
https://prometheus.io/download/#node_exporter

```bash
wget https://github.com/prometheus/node_exporter/releases/download/v1.5.0/node_exporter-1.5.0.linux-amd64.tar.gz
tar -xvf node_exporter-1.5.0.linux-amd64.tar.gz
cd node_exporter-1.5.0.linux-amd64
./node_exporter
```

### Test
Go to http://3.80.227.191:9100/metrics

### Install in Systemd
```bash
sudo useradd --no-create-home --shell /bin/false node_exporter
sudo cp node_exporter /usr/local/bin
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter

sudo vi /etc/systemd/system/node_exporter.service
```

```bash
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter
sudo systemctl status node_exporter
```

## Prometheus Configuration
```bash
sudo vi /etc/prometheus/prometheus.yml
```

```bash
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  # ...
  - job_name: "node1"
    static_configs:
      - targets: ["54.197.33.174:9090"]

```

Restart Prometheus
```bash
sudo systemctl restart prometheus
sudo systemctl status prometheus
```


## Configuration Node exporter TLS
https://blog.ruanbekker.com/blog/2021/10/10/setup-basic-authentication-on-node-exporter-and-prometheus/

```bash
sudo mkdir /etc/node_exporter
# If Debian based
openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout node_exporter.key -out node_exporter.crt -subj "/C=US/ST=California/L=Oakland/O=MyOrg/CN=localhost" -addext "subjectAltName = DNS:localhost"


# If RHEL based
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/node_exporter/node_exporter.key -out /etc/node_exporter/node_exporter.crt  -subj "/C=ZA/ST=CT/L=SA/O=VPN/CN=localhost"
```

```bash
sudo vi /etc/node_exporter/config.yml
```

```bash
tls_server_config:
  cert_file: node_exporter.crt
  key_file: node_exporter.key
```

```bash
sudo chown -R node_exporter:node_exporter /etc/node_exporter
```

```bash
sudo vi /etc/systemd/system/node_exporter.service
```

```bash
# If <= 1.4.0
ExecStart=/usr/local/bin/node_exporter --web.config=/etc/node_exporter/config.yml
# If >= 1.5.0
ExecStart=/usr/local/bin/node_exporter --web.config.file=/etc/node_exporter/config.yml

```

```bash
sudo systemctl daemon-reload
sudo systemctl restart node_exporter
sudo systemctl status node_exporter

```

test\
https://3.80.227.191:9100/metrics

```bash
curl -k https://localhost:9100/metrics
```

## Auth configuration Node exporter
```bash
# If Debian based
sudo apt update
sudo apt install apache2-utils
# If RHEL based
sudo yum install httpd-tools

htpasswd –nBC 12 "" | tr -d ':\n'

sudo vi /etc/node_exporter/config.yml
```
tls_server_config:
  cert_file: node_exporter.crt
  key_file: node_exporter.key
basic_auth_users:
  prometheus: $2yxxxxxtest
```bash
basic_auth_users:
  prometheus: $2yxxxxxtest
```

Test
```bash
# will failed
curl -k https://localhost:9100/metrics

# with authentication
curl -u prometheus:secret-password http://node02:9100/metrics

