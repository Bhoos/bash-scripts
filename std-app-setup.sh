#!/bin/bash
apt install -y rsync
# Create new user for access
useradd --create-home --shell /bin/bash joker
# Copy the ssh authorized keys
rsync --archive --chown=joker:joker ~/.ssh /home/joker
# Grant sudo priviledges
usermod -aG sudo joker
echo "joker   ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Disable ssh for root user
sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
service ssh restart

# Install curl
apt install -y curl

# Setup repo for node v12
curl -sL https://deb.nodesource.com/setup_12.x | bash -

# Setup repo for yarn
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# Update all
apt update

# Install dev tools
# gcc and g++ are required fro our node binary addons
apt install -y git gcc g++ make

# Install node
apt install -y nodejs

# Install yarn
apt install -y yarn

# Setup Personal access tokens for github package registry access
# Make sure the personal access token has read only access on packages
echo "
@bhoos:registry=https://npm.pkg.github.com/bhoos
//npm.pkg.github.com/bhoos/:_authToken={PERSONAL_ACCESS_TOKEN}
//npm.pkg.github.com/:_authToken={PERSONAL_ACCESS_TOKEN}
" > ~/.npmrc


