# Project Automation Script

This repository contains a `setup.sh` script that automates the environment setup for a project. This script installs necessary dependencies, copies configuration files, and creates the basic directory structure required for the project.

## Script Description

The `setup.sh` script performs the following tasks:

1. **Installs Required Packages**: Uses `apt-get` to install necessary packages.
2. **Copies Configuration Files**: Copies project configuration files to the appropriate locations.
3. **Creates Directory Structure**: Creates the basic directory structure needed for the project.
4. **Sets Up Zsh with Oh My Zsh and Plugins**: Installs and configures Zsh with Oh My Zsh, Powerlevel10k theme, and useful plugins.
5. **Installs and Configures Docker**: Sets up Docker with necessary dependencies and configurations.
6. **Installs Python and Node.js Environments**: Sets up Python with `pyenv` and Node.js with `nvm`.
7. **Configures SSH Server**: Installs and configures SSH server for secure access.

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

## Usage

1. Clone the repository:
    ```bash
    git clone https://github.com/nabomhalang/automation.git
    cd automation
    ```

2. Run the `setup.sh` script:
    ```bash
    bash setup.sh
    ```

    The script may require execution permissions, which can be granted with:
    ```bash
    chmod +x setup.sh
    ```

## Requirements

- Ubuntu or Debian-based Linux distribution
- `apt-get` package manager

## Contribution

Bug reports, feature requests, and pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change. To contribute, fork the repository and create a pull request.

