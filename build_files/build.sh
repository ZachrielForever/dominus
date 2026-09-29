#!/bin/bash

# ==============================================================================
# Dominus - custom uCore image build script
#
# Layers additional packages and services onto the uCore base image:
#   - Server administration and diagnostics tooling
#   - Storage and network forensic utilities
#   - Development contingency toolchain (heavy toolchains stay containerized)
#   - Cockpit (full) for web-based administration
#   - Tailscale for overlay network connectivity
#
# Runs inside the image build context (see Containerfile). The contents of
# system_files/ are copied into the image root before package installation.
# ==============================================================================

set -ouex pipefail

# Copy the contents of system_files/ from the git repo to /
cp -avf "/ctx/system_files"/. /

# ------------------------------------------------------------------------------
# Packages
# ------------------------------------------------------------------------------

# Core shell and productivity tools
dnf5 install -y \
    bat \
    btop \
    fastfetch \
    fzf \
    git \
    jq \
    micro \
    nano \
    python3 \
    python3-pip \
    qstat \
    rsync \
    tmux \
    tree \
    wget \
    yq

# Starship prompt (not in official repos; lives in COPR)
dnf5 copr enable -y atim/starship
dnf5 install -y starship

# Console fonts for physical display
dnf5 install -y \
    terminus-fonts

# System diagnostics and monitoring
dnf5 install -y \
    chrony \
    dmidecode \
    ethtool \
    file \
    iotop \
    lm_sensors \
    lsof \
    mtr \
    nmap \
    nmap-ncat \
    strace \
    sysstat \
    tcpdump \
    bind-utils \
    fzf

# Storage and disk utilities
dnf5 install -y \
    fio \
    gdisk \
    hdparm \
    ncdu \
    nvme-cli \
    p7zip \
    p7zip-plugins \
    sg3_utils \
    smartmontools \
    testdisk

# Compression and transfer utilities
dnf5 install -y \
    lz4 \
    pv \
    xz \
    zstd \
    pigz \
    zip \
    unzip

# Backup and synchronization
dnf5 install -y \
    rclone \
    restic

# Network and remote access
dnf5 install -y \
    arp-scan \
    mosh \
    openssl \
    socat \
    whois

# Text processing and script quality tools
dnf5 install -y \
    clippy \
    fd-find \
    ripgrep \
    rustfmt \
    shellcheck

# Database inspection
dnf5 install -y \
    sqlite

# File indexing
dnf5 install -y \
    plocate

# Containers
dnf5 install -y \
    podman-compose

# Development toolchain - host contingency tier
# Full development environments live in dedicated Distrobox containers;
# this tier covers quick builds, debugging, and emergency patching.
dnf5 install -y \
    binutils \
    cargo \
    clang \
    clang-tools-extra \
    cmake \
    gdb \
    gcc \
    make \
    ninja-build \
    rust \
    valgrind

# Python libraries and headers
dnf5 install -y \
    python3-devel \
    python3-httpx \
    python3-psutil \
    python3-pydantic \
    python3-requests

# Runtime language support
dnf5 install -y \
    perl \
    ruby

# SELinux - policy management, analysis, and troubleshooting
dnf5 install -y \
    checkpolicy \
    policycoreutils-python-utils \
    k3s-selinux \
    setools-console \
    setroubleshoot-server

# Cockpit - full feature set for web-based administration
dnf5 install -y \
    cockpit \
    cockpit-networkmanager \
    cockpit-podman \
    cockpit-sosreport \
    cockpit-storaged 

# Overlay networking
dnf5 install -y \
    tailscale

# Documentation
dnf5 install -y \
    man-db \
    man-pages

# ------------------------------------------------------------------------------
# Services
# ------------------------------------------------------------------------------

# Tailscale daemon (enrollment state persists in /var across image updates)
systemctl enable tailscaled

# Cockpit web interface (TCP 9090; socket-activated, no idle overhead)
systemctl enable cockpit.socket

# Podman system socket (rootless container management; template default)
systemctl enable podman.socket

# File index database refresh
systemctl enable plocate-updatedb.timer
