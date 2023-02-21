#!/bin/sh

apk add --no-cache --update-cache \
    git \
    lazygit \
    ripgrep \
    neovim \
    alpine-sdk \
    openssh

mkdir -p /root/.ssh \
# only this user should be able to read this folder (it may contain private keys)
chmod 0700 /root/.ssh \
# unlock the user
passwd -u root

echo -e "PasswordAuthentication no" >> /etc/ssh/sshd_config

echo "export XDG_DATA_HOME=/root/.config/nvim/data " >> /etc/profile.d/user_profile.sh

ssh-keygen -A

rm -f ./setup.sh
