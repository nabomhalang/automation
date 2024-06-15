# SSL Certificate Setup and Renewal Script

This repository contains a `setup.sh` script that automates the setup and renewal of SSL certificates using Let's Encrypt for a specified domain. The script installs necessary dependencies, configures Nginx, and sets up a cron job for automatic renewal of the SSL certificates.

## Script Description

The `setup.sh` script performs the following tasks:

1. **Installs Required Packages**: Checks for and installs necessary packages.
2. **Generates SSL Certificates**: Uses Let's Encrypt to generate SSL certificates.
3. **Configures Nginx**: Sets up Nginx configuration to use the generated SSL certificates.
4. **Sets Up Automatic Renewal**: Creates a script for automatic renewal of the SSL certificates and sets up a cron job to run this script periodically.

## Prerequisites

Before running the script, ensure that your system meets the following requirements:

- **Operating System**: Ubuntu or Debian-based Linux distribution.
- **Package Manager**: `apt-get` should be available.
- **Root Access**: You need to have root access to install packages and configure services.

## Installed Packages

The `setup.sh` script checks for and installs the following packages if they are not already installed:

- `nginx` (latest)
- `certbot` (latest)
- `expect` (latest)
- `cron` (latest)

## Usage

1. **Clone the repository**:
    ```bash
    git clone https://github.com/nabomhalang/ssl-setup-script.git
    cd ssl-setup-script
    ```

2. **Run the `setup.sh` script with your domain name as an argument**:
    ```bash
    sudo bash setup.sh example.com
    ```

    The script may require execution permissions, which can be granted with:
    ```bash
    chmod +x setup.sh
    ```

## Script Details

### Checking and Installing Required Packages

The script first checks if the necessary packages (`nginx`, `certbot`, `expect`, `cron`) are installed. If any of these packages are missing, it prompts the user to install them and exits.

### Generating SSL Certificates

The script uses `certbot` to generate SSL certificates for the specified domain. It requests the user to complete DNS-based verification for Let's Encrypt.

### Configuring Nginx

The script creates an Nginx configuration file for the specified domain. It sets up HTTP to HTTPS redirection and configures the SSL certificates for HTTPS connections.

The Nginx configuration file is created at `/etc/nginx/sites-available/<domain>.conf` and then linked to `/etc/nginx/sites-enabled/`.

### Setting Up Automatic Renewal

The script creates a renewal script at `/usr/bin/letsencryptrenew` that uses `expect` to handle the manual DNS challenge for Let's Encrypt. It then sets up a cron job to run this renewal script every Sunday at 4:30 AM.

## Nginx Configuration

The script generates an Nginx configuration file with the following content:

```nginx
server {
  listen 80;
  server_name example.com;
  return 301 https://example.com\$request_uri;
}

server {
  listen 443 ssl http2 default_server;
  server_name example.com;

  ssl_certificate      /etc/letsencrypt/live/example.com/fullchain.pem;
  ssl_certificate_key  /etc/letsencrypt/live/example.com/privkey.pem;

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
```

## Cron Job for SSL Certificate Renewal

The script sets up a cron job to run the renewal script every Sunday at 4:30 AM. This ensures that the SSL certificates are renewed automatically before they expire.

### Renewal Script

The renewal script is created at `/usr/bin/letsencryptrenew` and contains the following content:

```bash
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
```
This script uses expect to automate the manual DNS challenge process required by Let's Encrypt for certificate renewal. It then restarts Nginx to apply the renewed certificates.

### Adding the Cron Job

The script adds a cron job to run the renewal script. The cron job is configured as follows:

```bash
(crontab -l ; echo "30 4 * * 0 /usr/bin/letsencryptrenew") | crontab -
```
This cron job ensures that the renewal script runs every Sunday at 4:30 AM. This timing is chosen to minimize any potential disruption to your services.

### Enabling and Starting the Cron Service

The script ensures that the cron service is enabled and running to execute the scheduled cron jobs:

```bash
sudo systemctl enable cron
sudo systemctl start cron
```
This guarantees that the cron jobs are executed as scheduled.

## Logging

All actions performed by the script are logged to `/var/log/ssl_setup.log`. This includes:

- Package installation checks and installations
- SSL certificate generation
- Nginx configuration setup
- Cron job setup for automatic certificate renewal

You can review this log file to troubleshoot any issues that arise during the setup process. The log file provides detailed information about each step the script performs, which can help diagnose and resolve any problems.

## Contribution

Bug reports, feature requests, and pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change. To contribute, fork the repository and create a pull request.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.



