# 프로젝트 자동화 스크립트

이 리포지토리는 프로젝트 환경 설정을 자동화하는 `setup.sh` 스크립트를 포함하고 있습니다. 이 스크립트를 사용하면 필요한 의존성을 설치하고, 설정 파일을 복사하며, 기본 디렉토리 구조를 생성할 수 있습니다.

## 스크립트 설명

`setup.sh` 스크립트는 다음과 같은 작업을 수행합니다:

1. **필요한 패키지 설치**: 스크립트는 `apt-get`을 사용하여 필요한 패키지를 설치합니다.
2. **설정 파일 복사**: 스크립트는 프로젝트의 설정 파일을 적절한 위치로 복사합니다.
3. **디렉토리 구조 생성**: 스크립트는 프로젝트에 필요한 기본 디렉토리 구조를 생성합니다.

## 설치되는 패키지

`setup.sh` 스크립트는 다음과 같은 패키지를 설치합니다:

### 공통 패키지

- `zsh` (버전 최신)
- `git` (버전 최신)
- `tmux` (버전 최신)
- `htop` (버전 최신)
- `curl` (버전 최신)
- `wget` (버전 최신)
- `build-essential` (버전 최신)

### Python 빌드 의존성

- `libssl-dev` (버전 최신)
- `zlib1g-dev` (버전 최신)
- `libbz2-dev` (버전 최신)
- `libreadline-dev` (버전 최신)
- `libsqlite3-dev` (버전 최신)
- `llvm` (버전 최신)
- `libncurses5-dev` (버전 최신)
- `libncursesw5-dev` (버전 최신)
- `xz-utils` (버전 최신)
- `tk-dev` (버전 최신)
- `libffi-dev` (버전 최신)
- `liblzma-dev` (버전 최신)
- `python-openssl` (버전 최신)

### Neovim 빌드 의존성

- `ninja-build` (버전 최신)
- `gettext` (버전 최신)
- `libtool` (버전 최신)
- `libtool-bin` (버전 최신)
- `autoconf` (버전 최신)
- `automake` (버전 최신)
- `cmake` (버전 최신)
- `g++-9` (버전 최신)
- `pkg-config` (버전 최신)
- `unzip` (버전 최신)
- `curl` (버전 최신)

### Docker 관련 패키지

- `docker-ce` (버전 최신)
- `docker-ce-cli` (버전 최신)
- `containerd.io` (버전 최신)
- `docker-buildx-plugin` (버전 최신)
- `docker-compose-plugin` (버전 최신)

### 기타 패키지

- `openssh-server` (버전 최신)
- `ca-certificates` (버전 최신)

## 사용법

1. 리포지토리를 클론합니다:
    ```bash
    git clone https://github.com/nabomhalang/automation.git
    cd automation
    ```

2. `setup.sh` 스크립트를 실행합니다:
    ```bash
    bash setup.sh
    ```

    이 스크립트는 실행 권한이 필요할 수 있으므로, 다음과 같이 실행 권한을 부여할 수 있습니다:
    ```bash
    chmod +x setup.sh
    ```

## 요구사항

- Ubuntu 또는 Debian 기반의 리눅스 배포판
- `apt-get` 패키지 매니저
