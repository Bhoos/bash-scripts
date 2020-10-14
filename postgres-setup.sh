#!/bin/bash
apt-get install postgresql

# Enable service
systemctl enable postgresql

# Create user
su postgres
createuser bhoos
createdb bhoos

# Create linux user
adduser bhoos
