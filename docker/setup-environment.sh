#!/bin/sh

# TODO: Let user to config which custom packages want to install
#       apart from required ones


# Required packages to install
apk add --no-cache --update-cache \
    git \
    ripgrep \
    neovim \
    alpine-sdk \
    openssh

# Custom package example
apk add --no-cache --update-cache lazygit


# SSH configuration
mkdir -p /root/.ssh
# Only this user should be able to read this folder (it may contain private keys)
chmod 0700 /root/.ssh
passwd -u root # unlock the user
echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
ssh-keygen -A

# Nvim custom runtime path at container startup
echo "export XDG_DATA_HOME=/root/.config/nvim/data " >> /etc/profile.d/user_profile.sh

# Auto remove setup.sh script to clean the image
rm -f ./"$(basename "$0")"