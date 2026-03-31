#!/bin/bash
set -e

# First-boot setup on empty PVC: fix ownership, create .ssh, generate host keys
chown thomas:thomas /home/thomas
mkdir -p /home/thomas/.ssh
chmod 700 /home/thomas/.ssh
chown thomas:thomas /home/thomas/.ssh

if [ ! -f /home/thomas/.ssh/ssh_host_ed25519_key ]; then
    echo "Generating SSH host keys..."
    ssh-keygen -t ed25519 -f /home/thomas/.ssh/ssh_host_ed25519_key -N "" -q
    ssh-keygen -t rsa -b 4096 -f /home/thomas/.ssh/ssh_host_rsa_key -N "" -q
fi

exec /usr/sbin/sshd -D -e
