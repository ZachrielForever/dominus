#!/bin/bash

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

### Install packages

# Dominus server toolbox - curated per the migration charter
# Tier 1: everyday host tooling
dnf5 install -y \
    tmux \
    btop \
    htop \
    git \
    nano \
    micro \
    python3 \
    qstat \
    rsync \
    jq

# Tier 2: diagnostic artillery for when containers misbehave
dnf5 install -y \
    strace \
    lsof \
    file \
    tree \
    bind-utils \
    nmap-ncat \
    lm_sensors \
    smartmontools \
    glances \
    iperf3 \
    mtr \
    tcpdump \
    chrony \
    zstd \
    pigz

# SELinux tooling for the httpd_sys_content_t / semanage / restorecon rituals
dnf5 install -y policycoreutils-python-utils

# SELinux troubleshooting backend for Cockpit's SELinux page
dnf5 install -y setroubleshoot-server

# Cockpit - FULL flavor, not the lite experience
dnf5 install -y \
    cockpit \
    cockpit-storaged \
    cockpit-networkmanager \
    cockpit-podman \
    cockpit-packagekit \
    cockpit-terminal \
    cockpit-sosreport

# Overlay networking - the lifeline to Helius
dnf5 install -y tailscale

### Services

# Tailscale daemon on boot (enrollment state lives in /var, survives updates)
systemctl enable tailscaled

# Podman socket for rootless management (template default, kept)
systemctl enable podman.socket

# Cockpit web UI (port 9090) - socket-activated, no idle cost
systemctl enable cockpit.socket
