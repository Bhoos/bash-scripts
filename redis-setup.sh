#!/bin/bash

# Extract the VPC private ip address (digital ocean)
export PRIVATE_IP=$(curl -s http://169.254.169.254/metadata/v1/interfaces/private/0/ipv4/address)
# Get the total available memory in MB
export TOTAL_MEM_MB=$(free -m | grep Mem | awk '{print $2}')
# Use all expect 300MB memory for redis
export REDIS_MEM_MB=$((TOTAL_MEM_MB - 300))

# Update the system
apt -y update


# Set overcommit to 1, Red details at: 
# https://engineering.pivotal.io/post/virtual_memory_settings_in_linux_-_the_problem_with_overcommit/
sysctl vm.overcommit_memory=1
echo "vm.overcommit_memory=1" >> /etc/sysctl.conf

# Disable THP (Transparent Huge Pages) for redis efficiency
# Make sure the THP is disabled within restarts
echo "
[Unit]
Description=Disable Transparent Huge Pages (THP)
DefaultDependencies=no
After=sysinit.target local-fs.target
Before=redis.service
[Service]
Type=oneshot
ExecStart=/bin/sh -c 'echo never | tee /sys/kernel/mm/transparent_hugepage/enabled > /dev/null'
[Install]
WantedBy=basic.target
" > /etc/systemd/system/disable-transparent-huge-pages.service
systemctl daemon-reload
systemctl enable disable-transparent-huge-pages
systemctl start disable-transparent-huge-page

# Install the redis server (5.0)
apt install -y redis-server

# Update configuration to run via systemd
sed -i "s/^supervised .*/supervised systemd/g" /etc/redis/redis.conf
# Change bind address to the private VPC
sed -i "s/^bind .*/bind $PRIVATE_IP/g" /etc/redis/redis.conf
# Allow connecting from remote clients
sed -i "s/^protected-mode yes/protected-mode no/g" /etc/redis/redis.conf

# Setup the eviction policy to lru
sed -i "s/^# maxmemory-policy .*/maxmemory-policy allkeys-lru/g" /etc/redis/redis.conf
sed -i "s/^# maxmemory .*/maxmemory ${REDIS_MEM_MB}mb/g" /etc/redis/redis.conf

# Restart
systemctl daemon-reload
systemctl enable redis
systemctl restart redis

