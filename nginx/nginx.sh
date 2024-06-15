#!/bin/bash

# Log file
LOGFILE="/var/log/ssl_setup.log"
exec > >(tee -i $LOGFILE)
exec 2>&1

# Function to check if a package is installed
function check_package {
    dpkg -s "$1" &> /dev/null

    if [ $? -ne 0 ]; then
        echo "Package $1 is not installed. Please install it first."
        exit 1
    fi
}

# Function to log messages
function log_and_show {
    echo "$1" | tee -a $LOGFILE
}

# Check for necessary packages
necessary_packages=("nginx" "certbot" "expect" "cron")
for package in "${necessary_packages[@]}"; do
    check_package $package
done

# Check if domain name is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <domain_name>"
    exit 1
fi

DOMAIN=$1

# Remove existing nginx configuration for the domain if it exists
if [ -f "/etc/nginx/sites-available/$DOMAIN.conf" ]; then
    sudo rm "/etc/nginx/sites-available/$DOMAIN.conf"
    sudo rm "/etc/nginx/sites-enabled/$DOMAIN.conf"
fi

# Remove existing cron job for certificate renewal
(crontab -l | grep -v "/usr/bin/letsencryptrenew" | crontab -)

# Create directory for SSL certificates if it doesn't exist
mkdir -p /etc/ssl/certs
sudo update-ca-certificates

# Install Let's Encrypt
sudo apt-get install -y letsencrypt

# Generate SSL certificates
sudo certbot certonly --manual --preferred-challenges dns -d "*.$DOMAIN" -d "$DOMAIN"

# Configure nginx
NGINX_CONF="/etc/nginx/sites-available/$DOMAIN.conf"
sudo bash -c "cat > $NGINX_CONF" << EOF
server {
  listen 80;
  server_name $DOMAIN;
  return 301 https://$DOMAIN\$request_uri;
}

server {
  listen 443 ssl http2 default_server;
  server_name $DOMAIN;

  ssl_certificate      /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
  ssl_certificate_key  /etc/letsencrypt/live/$DOMAIN/privkey.pem;

  location ^~/ {
    proxy_pass http://localhost:3000;
    proxy_set_header Host \$http_host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection "upgrade";
  }
}
EOF

# Enable the nginx configuration
sudo ln -s /etc/nginx/sites-available/$DOMAIN.conf /etc/nginx/sites-enabled/
sudo systemctl restart nginx

# Create the renewal script
RENEW_SCRIPT="/usr/bin/letsencryptrenew"
sudo bash -c "cat > $RENEW_SCRIPT" << EOF
#!/usr/bin/expect -f

spawn sudo certbot certonly --manual --preferred-challenges dns -d "*.$DOMAIN" -d "$DOMAIN"

expect {
    "What would you like to do?" {
        send "2\r"
        exp_continue
    }
    eof
}

spawn sudo systemctl restart nginx

expect eof
EOF

# Make the renewal script executable
sudo chmod +x $RENEW_SCRIPT

# Add cron job for automatic renewal
(crontab -l ; echo "30 4 * * 0 $RENEW_SCRIPT") | crontab -

# Enable cron service
sudo systemctl enable cron
sudo systemctl start cron

log_and_show "SSL certificate setup and renewal configuration completed for $DOMAIN"

