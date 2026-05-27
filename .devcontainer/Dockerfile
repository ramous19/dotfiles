# syntax=docker/dockerfile:1
FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

ARG USERNAME=vscode

# Install minimum prereqs; chezmoi will install the rest on container create.
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      curl wget git ca-certificates gnupg lsb-release sudo unzip vim \
      build-essential fontconfig \
 && rm -rf /var/lib/apt/lists/*

# Install chezmoi to /usr/local/bin so it's on PATH for everyone.
RUN sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /usr/local/bin

USER ${USERNAME}
WORKDIR /home/${USERNAME}
