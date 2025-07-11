# syntax=docker/dockerfile:1
# enable here documents.
# RUN cat <<EOF >> /home/vscode/.bashrc
#
# EOF

FROM ubuntu:latest
# suppress clear apt cache
RUN rm /etc/apt/apt.conf.d/docker-clean

# Set locale and timezone
ENV LANG=ja_JP.UTF-8
ENV LC_ALL=ja_JP.UTF-8
ENV LC_CTYPE=ja_JP.UTF-8
ENV TZ=Asia/Tokyo

ARG USERNAME=vscode
ARG UID=10000
ARG GID=$UID

# Setup user and group id
# Remove all general users and create a new user for USER direction.
RUN set -eux; \
    for i in $(awk -F: '$3 >= 1000 && $3 <= 60000 { print $1 }' /etc/passwd); do \
    userdel $i; \
    done; \
    for i in $(awk -F: '$3 >= 1000 && $3 <= 60000 { print $1 }' /etc/passwd); do \
    groupdel $i; \
    done; \
    groupadd --gid "${GID}" "${USERNAME}"; \
    useradd --uid "${UID}" --gid "${GID}" -s /bin/bash -m "${USERNAME}"

# Install packages
ENV DEBIAN_FRONTEND=noninteractive

# Enable sudo
# RUN --mount=type=cache,target=/var/cache/apt \
#     --mount=type=cache,sharing=locked,target=/var/lib/apt \
#     apt-get update \
#     && apt-get install -y sudo \
#     && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
#     && chmod 0440 /etc/sudoers.d/$USERNAME

# https://github.com/moby/buildkit/issues/1662#issuecomment-683962222
RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,sharing=locked,target=/var/lib/apt \
    apt-get update \
    && apt-get install --no-install-recommends -y \
    # Basic tools
    # ssh is required to handle GitHub in the container
    git ssh \
    # System tools
    locales tzdata \
    # Configure locale
    && locale-gen ja_JP.UTF-8 \
    && update-locale LANG=ja_JP.UTF-8 \
    # Configure timezone
    && ln -fs /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata

# Default user
USER vscode
