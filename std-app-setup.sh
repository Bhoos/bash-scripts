#!/bin/bash

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
apt install yarn

# Setup Personal access tokens for github package registry access
# Make sure the personal access token has read only access on packages
echo "
@bhoos:registry=https://npm.pkg.github.com/bhoos
//npm.pkg.github.com/bhoos/:_authToken={PERSONAL_ACCESS_TOKEN}
//npm.pkg.github.com/:_authToken={PERSONAL_ACCESS_TOKEN}
" > ~/.npmrc


