# Project Automation Script

This repository contains a `setup.sh` script that automates the environment setup for a project. This script installs necessary dependencies, copies configuration files, creates the basic directory structure, and configures various services.

## Script Description

The `setup.sh` script performs the following tasks:

1. **Installs Required Packages**: Uses `apt-get` to install necessary packages.
2. **Sets Up Zsh with Oh My Zsh and Plugins**: Installs and configures Zsh with Oh My Zsh, Powerlevel10k theme, and useful plugins.
3. **Installs and Configures Docker**: Sets up Docker with necessary dependencies and configurations.
4. **Installs Python and Node.js Environments**: Sets up Python with `pyenv` and Node.js with `nvm`.
5. **Configures SSH Server**: Installs and configures SSH server for secure access.
6. **Configures Let's Encrypt for SSL**: Sets up SSL certificates using Let's Encrypt and configures automatic renewal.

## Installed Packages

The `setup.sh` script installs the following packages:

### Common Packages

- `zsh` (latest)
- `git` (latest)
- `tmux` (latest)
- `htop` (latest)
- `curl` (latest)
- `wget` (latest)
- `build-essential` (latest)
- `nginx` (latest)
- `certbot` (latest)
- `expect` (latest)
- `cron` (latest)

### Python Build Dependencies

- `libssl-dev` (latest)
- `zlib1g-dev` (latest)
- `libbz2-dev` (latest)
- `libreadline-dev` (latest)
- `libsqlite3-dev` (latest)
- `llvm` (latest)
- `libncurses5-dev` (latest)
- `libncursesw5-dev` (latest)
- `xz-utils` (latest)
- `tk-dev` (latest)
- `libffi-dev` (latest)
- `liblzma-dev` (latest)
- `python-openssl` (latest)

### Neovim Build Dependencies

- `ninja-build` (latest)
- `gettext` (latest)
- `libtool` (latest)
- `libtool-bin` (latest)
- `autoconf` (latest)
- `automake` (latest)
- `cmake` (latest)
- `g++-9` (latest)
- `pkg-config` (latest)
- `unzip` (latest)
- `curl` (latest)

### Docker Packages

- `docker-ce` (latest)
- `docker-ce-cli` (latest)
- `containerd.io` (latest)
- `docker-buildx-plugin` (latest)
- `docker-compose-plugin` (latest)

### Other Packages

- `openssh-server` (latest)
- `ca-certificates` (latest)

## Zsh Theme and Plugins

The `setup.sh` script installs the following Zsh theme and plugins:

### Oh My Zsh

[Oh My Zsh](https://ohmyz.sh/) is a framework for managing Zsh configuration. The script installs Oh My Zsh in the `/usr/share/oh-my-zsh` directory.

### Powerlevel10k Theme

[Powerlevel10k](https://github.com/romkatv/powerlevel10k) is a fast and flexible Zsh theme. The script installs this theme in the `/usr/share/oh-my-zsh/custom/themes/powerlevel10k` directory.

### Plugins

- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting): Highlights commands as you type, helping to identify syntax errors.
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions): Suggests commands as you type based on command history.

## SSH Configuration

The `setup.sh` script also configures the SSH server with the following settings:

- Disables password authentication to enhance security.
- Disables root login to prevent unauthorized access.
- Enables public key authentication for secure access.

The following changes are made in the `/etc/ssh/sshd_config` file:

```text
PasswordAuthentication no
PermitRootLogin no
ChallengeResponseAuthentication no
UsePAM no
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
```

### Setting Up SSH Keys

To use SSH with public key authentication, you need to generate an SSH key pair and place the public key in the `~/.ssh/authorized_keys` file on the server. Here's how you can do it:

1. **Generate SSH Key Pair**:
    ```bash
    ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
    ```

    This command will create a new SSH key pair. By default, the keys will be saved in the `~/.ssh` directory.

2. **Copy Public Key to Server**:
    ```bash
    ssh-copy-id username@server_ip
    ```

    Replace `username` with your server username and `server_ip` with your server's IP address. This command will copy your public key to the server and add it to the `~/.ssh/authorized_keys` file.

3. **Verify SSH Access**:
    ```bash
    ssh username@server_ip
    ```

    After copying the public key, you should be able to log in to the server without being prompted for a password.

By configuring SSH to use public key authentication, you enhance the security of your server by requiring a cryptographic key for login instead of a password.

## SSL Configuration with Let's Encrypt

The `setup.sh` script sets up SSL certificates using Let's Encrypt. The script performs the following tasks:

1. **Installs Let's Encrypt**: Uses `apt-get` to install the Let's Encrypt client (`certbot`).
2. **Generates SSL Certificates**: Uses `certbot` to generate SSL certificates for the provided domain.
3. **Configures Nginx for SSL**: Sets up Nginx configuration to use the generated SSL certificates.

### SSL Certificate Renewal

The script also sets up a cron job to automatically renew the SSL certificates. The cron job runs the following command:

```bash
/usr/bin/letsencryptrenew
```

The cron job is configured to run every Sunday at 4:30 AM. The renewal script uses certbot to renew the certificates and restarts Nginx to apply the new certificates.

## Usage

1. Clone the repository:
    ```bash
    git clone https://github.com/nabomhalang/automation.git
    cd automation
    ```

2. Run the `setup.sh` script with your domain name as an argument:
    ```bash
    sudo bash setup.sh example.com
    ```

    The script may require execution permissions, which can be granted with:
    ```bash
    chmod +x setup.sh
    ```

## Contribution

Bug reports, feature requests, and pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change. To contribute, fork the repository and create a pull request.

