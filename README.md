# Boilerplate for VSCode Dev Container

VSCode の dev container を使用するための雛形です。

## Install Docker Engine

[Install using the `apt` repository](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository)

### install the latest Docker Engine

```bash
# Add Docker's official GPG key:
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update

sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### setup user

ユーザを`docker`グループに入れることで、`sudo`を使わないでDocker imageを起動できるようになる。

```bash
sudo usermod -aG docker $USER
```

グループへの参加は、サイドログインしないと有効にならない。

### clone boilerplate files

### Step 1

このレポジトリを次のコマンドでクローンしてください。

```bash
git clone https://github.com/nosuz/dev_container.git
cd dev_container
rm -r .git
git init
git branch -m main # if needed

code .
# Edit .devcontainer/Dockerfile to install required APT packages before rebuilding this container.
```

### Option 1: ホストのUIDが1000以外で、ホームディレクトリへの書き込みが必要な場合

UIDは変更できますが、コンテナ内のホームディレクトリはイメージを作成したときのUIDでディレクトリとファイルが作成されます。そのため、UIDを変更しても書き込めないことがあります。その場合は、新しくイメージを作成し直す必要があります。

#### .devcontainer/.env

ホストのUIDとGIDを設定します。

```bash
UID=1000
GID=1000
```

この`UID`と`GID`を含む`.env`ファイルは、`generate_env.py`または`generate_env.sh`を`.devcontainer`を実行することで作成できます。ただしこれらのスクリプトは、スクリプトのあるディレクトリに`.env`ファイルを作成します。

#### .devcontainer/compose.yaml

```yaml
services:
  app:
    build:
      # set by `.env`
      args:
        UID: ${UID:-1000}
        GID: ${GID:-1000}
```

#### .devcontainer/Dockerfile

```Dockerfile
ARG USERNAME=ubuntu
ARG UID=$UID
ARG GID=$GID

# Remove user if already exist and create new user.
RUN set -eux; \
    if getent passwd "${UID}" > /dev/null; then \
    echo "UID ${UID} already exists. Deleting..."; \
    userdel -f $(getent passwd "${UID}" | cut -d: -f1) || true; \
    fi; \
    if getent group "${GID}" > /dev/null; then \
    echo "GID ${GID} already exists. Deleting..."; \
    groupdel $(getent group "${GID}" | cut -d: -f1) || true; \
    fi; \
    groupadd --gid "${GID}" "${USERNAME}"; \
    useradd --uid "${UID}" --gid "${GID}" -s /bin/bash -m "${USERNAME}"
```

### Option 2: sudoが必要な場合

#### .devcontainer/Dockerfile

```Dockerfile
# Enable sudo
ARG USERNAME=ubuntu
RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,sharing=locked,target=/var/lib/apt \
    apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME
```

### Step 2

必要なパッケージをインストールするように Dockerfile を編集してください。

### Step 3

このディレクトリを VSCode で開き、コマンドパレット(Ctrl + Shift + P)で Dev Containers: Rebuild container を実行すると、コンテナイメージが作成されて接続されます。

### user name and id

このコンテナは、コンテナを開いたユーザと同じ ID で実行されます。そのため権限の問題なしにディレクトリを共有できます。ただしコンテナ内のユーザ名は、`ubuntu`となり、`ls -l`で共有ディレクトリを見るとユーザ名が元と変わって`ubuntu`になります。

また、`.devcontainer/devcontainer.json`の`remoteUser`で`root`を指定した場合には、root 権限で実行されます。

## VSCode settings and extensions

Dev container では、VSCode の設定と機能拡張がリセットされます。そこで、必要な設定と機能拡張を`.devcontainer/devcontainer.json`の`customizations`に記載します。

```json
// devcontainer.json
{
  "customizations": {
    "vscode": {
      "settings": {},
      "extensions": ["mhutchie.git-graph", "streetsidesoftware.code-spell-checker"]
    }
  }
}
```

初期設定では、[Code Spell Checker](https://marketplace.visualstudio.com/items?itemName=streetsidesoftware.code-spell-checker)と[Git Graph](https://marketplace.visualstudio.com/items?itemName=mhutchie.git-graph)がインストールされます。

## Git

editor が設定されていないため、コマンドラインから`git commit --amend`など編集が必要な操作ができません。そこで、`.git/config`に`editor`の設定を加えます。

```ini
[core]
 editor = code --wait
```

ローカルの`~/.gitconfig`に設定がある場合は、デフォルト設定ではこのファイルがコピーされるのでコンテナ毎の設定は不要です。

### GitHub access

GitHub は、`ssh`パッケージをインストールしてあれば他に特別な設定無く使用できると思います。次のコマンドで GitHub への接続を確認できます。

```command
$ ssh -T git@github.com
Hi nosuz! You've successfully authenticated, but GitHub does not provide shell access.
```

## Docker Images

古いイメージは、次のコマンドで一括削除できます。

```bash
docker image prune
```

## Codex

`codex.devcontainer`は、

## 参考

- [Docker や VSCode + Remote-Container のパーミッション問題に立ち向かう](https://zenn.dev/forrep/articles/8c0304ad420c8e)
- [Parallel use of cache mount can fail #1662](https://github.com/moby/buildkit/issues/1662#issuecomment-683962222)
- [Example: cache apt packages](https://docs.docker.com/reference/dockerfile/?__readwiseLocation=#example-cache-apt-packages)
