#!/bin/bash

LOGFILE="/var/log/setup-env.log"
exec > >(tee -i $LOGFILE)
exec 2>&1

function log_and_show {
    echo "$1" | tee -a $LOGFILE
}

# ProgressBar 함수 정의
function ProgressBar {
    let _progress=(${1}*100/${2}*100)/100
    let _done=(${_progress}*4)/10
    let _left=40-$_done
    _fill=$(printf "%${_done}s")
    _empty=$(printf "%${_left}s")
    printf "\r%s : [%s%s] %d%%" "$3" "${_fill// /#}" "${_empty// /-}" $_progress
}

function install_package {
    local package=$1
    sudo apt-get install -y $package >> $LOGFILE 2>&1
    local EXIT_CODE=$?
    if [ $EXIT_CODE -ne 0 ]; then
        log_and_show "Error installing $package. Check the log for details."
        exit 1
    fi
}

function run_command {
    local cmd=$1
    echo "Running: $cmd"
    eval "$cmd" >> $LOGFILE 2>&1
    local EXIT_CODE=$?
    if [ $EXIT_CODE -ne 0 ]; then
        log_and_show "Error running command: $cmd. Check the log for details."
        exit 1
    fi
    echo "Done."
}

log_and_show "Starting environment setup..."

# 기본 패키지 배열
common_packages=(
    zsh
    git
    tmux
    htop
    curl
    wget
    build-essential
    nginx
    certbot
    expect
    cron
)

# Python 빌드 의존성 배열
python_build_packages=(
    libssl-dev
    zlib1g-dev
    libbz2-dev
    libreadline-dev
    libsqlite3-dev
    llvm
    libncurses5-dev
    libncursesw5-dev
    xz-utils
    tk-dev
    libffi-dev
    liblzma-dev
    python-openssl
)

# Neovim 빌드 의존성 배열
neovim_build_packages=(
    ninja-build
    gettext
    libtool
    libtool-bin
    autoconf
    automake
    cmake
    g++-9
    pkg-config
    unzip
    curl
)

# Docker 관련 패키지 배열
docker_packages=(
    docker-ce
    docker-ce-cli
    containerd.io
    docker-buildx-plugin
    docker-compose-plugin
)

# 패키지 설치 함수
install_packages() {
    local category=$1
    shift
    local packages=("$@")
    local total=${#packages[@]}
    local count=0

    log_and_show "Installing $category packages..."

    for package in "${packages[@]}"; do
        count=$((count + 1))
        ProgressBar $count $total $package
        install_package $package
        echo -ne "\r\033[K"
        ProgressBar $count $total $package
        echo -ne "\r\033[K"
        echo "$package installed."
    done
}

# 패키지 설치
install_packages "common" "${common_packages[@]}"
install_packages "Python build dependencies" "${python_build_packages[@]}"
install_packages "Neovim build dependencies" "${neovim_build_packages[@]}"
install_packages "Docker" "${docker_packages[@]}"

# 최신 버전의 Neovim 설치
log_and_show "Installing latest Neovim..."

run_command "sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 60 --slave /usr/bin/g++ g++ /usr/bin/g++-9"

if [ -d /usr/local/src/neovim ]; then
    run_command "sudo rm -rf /usr/local/src/neovim"
fi

run_command "sudo git clone https://github.com/neovim/neovim /usr/local/src/neovim"
cd /usr/local/src/neovim
run_command "sudo git checkout stable"
run_command "sudo make CMAKE_BUILD_TYPE=Release"
run_command "sudo make install"
log_and_show "Neovim installation completed."

# Docker 설치
log_and_show "Removing old Docker packages..."
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove -y $pkg; done

# Add Docker's official GPG key
log_and_show "Adding Docker's official GPG key..."
sudo apt-get update
install_package ca-certificates
install_package curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources
log_and_show "Adding Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

log_and_show "Installing Docker packages..."
install_packages "Docker" "${docker_packages[@]}"
log_and_show "Docker installation completed."

# Oh My Zsh 설치
if [ ! -d /usr/share/oh-my-zsh ]; then
    run_command "sudo git clone https://github.com/ohmyzsh/ohmyzsh.git /usr/share/oh-my-zsh"
fi

# Powerlevel10k 테마 설치
if [ ! -d /usr/share/oh-my-zsh/custom/themes/powerlevel10k ]; then
    run_command "sudo git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /usr/share/oh-my-zsh/custom/themes/powerlevel10k"
fi

# 플러그인 설치
if [ ! -d /usr/share/oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]; then
    run_command "sudo git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /usr/share/oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
fi

if [ ! -d /usr/share/oh-my-zsh/custom/plugins/zsh-autosuggestions ]; then
    run_command "sudo git clone https://github.com/zsh-users/zsh-autosuggestions /usr/share/oh-my-zsh/custom/plugins/zsh-autosuggestions"
fi

# /etc/zshrc 파일 설정
log_and_show "Configuring /etc/zshrc..."
sudo bash -c 'cat << EOF > /etc/zshrc
export PATH=/usr/local/bin:$PATH

# Oh My Zsh 설치 디렉터리
export ZSH="/usr/share/oh-my-zsh"

# 테마 설정
ZSH_THEME="powerlevel10k/powerlevel10k"

# 플러그인 설정
plugins=(
    git
    zsh-syntax-highlighting
    zsh-autosuggestions
)

# Oh My Zsh 초기화
source \$ZSH/oh-my-zsh.sh

# Powerlevel10k 설정
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# nvm 설정
export NVM_DIR="\$HOME/.nvm"
[ -s "/usr/share/nvm/nvm.sh" ] && \. "/usr/share/nvm/nvm.sh"  # This loads nvm
[ -s "/usr/share/nvm/bash_completion" ] && \. "/usr/share/nvm/bash_completion"  # This loads nvm bash_completion

# pyenv 설정
export PATH="\$HOME/.pyenv/bin:\$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
    eval "\$(pyenv init --path)"
    eval "\$(pyenv init -)"
fi
EOF'
log_and_show "/etc/zshrc configuration completed."

# 모든 사용자의 기본 셸을 Zsh로 변경하고 .zshrc 설정
log_and_show "Configuring users' .zshrc and default shell to Zsh..."

for user_home in /home/* /root; do
    if [ -d "$user_home" ]; then
        username=$(basename $user_home)

        # 기본 셸 변경
        run_command "sudo chsh -s $(which zsh) $username"

        # .zshrc 설정
        sudo bash -c "cat << 'EOF' > $user_home/.zshrc
if [[ -r \"\${XDG_CACHE_HOME:-\$HOME/.cache}/p10k-instant-prompt-\${(%):-%n}.zsh\" ]]; then
  source \"\${XDG_CACHE_HOME:-\$HOME/.cache}/p10k-instant-prompt-\${(%):-%n}.zsh\"
fi

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
if [ -f /etc/zshrc ]; then source /etc/zshrc; fi
EOF"

        sudo chown $username:$username $user_home/.zshrc
    fi
done
log_and_show "Users' .zshrc configuration completed."

# /etc/skel/.zshrc 파일 설정
log_and_show "Configuring /etc/skel/.zshrc..."

sudo bash -c 'cat << 'EOF' > /etc/skel/.zshrc
if [[ -r "\${XDG_CACHE_HOME:-\$HOME/.cache}/p10k-instant-prompt-\${(%):-%n}.zsh" ]]; then
  source "\${XDG_CACHE_HOME:-\$HOME/.cache}/p10k-instant-prompt-\${(%):-%n}.zsh"
fi

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
if [ -f /etc/zshrc ]; then source /etc/zshrc; fi
EOF'
log_and_show "/etc/skel/.zshrc configuration completed."

# nvm 설치 및 최신 안정 버전의 Node.js 설치
log_and_show "Installing nvm..."

sudo mkdir -p /usr/share/nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | NVM_DIR=/usr/share/nvm bash
source /usr/share/nvm/nvm.sh
log_and_show "Installing latest stable Node.js..."
nvm install stable
log_and_show "Node.js installation completed."

# pyenv 설치 및 최신 버전의 Python 설치
log_and_show "Installing pyenv..."

curl https://pyenv.run | bash
if [ -d ~/.pyenv ]; then
    sudo mv ~/.pyenv /usr/share/pyenv
fi
export PATH="/usr/share/pyenv/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
log_and_show "Installing latest Python..."
pyenv install 3.12.4  # 최신 버전으로 변경 가능
pyenv global 3.12.4
log_and_show "Python installation completed."

# SSH 설치 및 설정
log_and_show "Installing SSH server..."
install_package openssh-server

log_and_show "Configuring SSH server..."

sudo systemctl enable ssh
sudo systemctl start ssh

# SSH 설정 파일 수정
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/#ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/#UsePAM yes/UsePAM no/' /etc/ssh/sshd_config
sudo sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's|#AuthorizedKeysFile.*|AuthorizedKeysFile .ssh/authorized_keys|' /etc/ssh/sshd_config

sudo systemctl restart ssh
log_and_show "SSH server installation and configuration completed. Password login disabled, only key authentication allowed."

log_and_show "Zsh, nvm, pyenv, Docker, and SSH server installation and configuration completed."

