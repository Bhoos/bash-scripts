#!/bin/bash
apt -y update
apt -y upgrade

# Include postgreSQL repository
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | tee  /etc/apt/sources.list.d/pgdg.list
apt update

# Install postgresql v13
apt install -y postgresql-13

export DB_NAME="user_db"

# Create user and database to start with
su - postgres --command "createuser bhoos"
su - postgres --command "createdb $DB_NAME"

# Extract the VPC private ip address (digital ocean)
export PRIVATE_IP=$(curl -s http://169.254.169.254/metadata/v1/interfaces/private/0/ipv4/address)

# Accept connection in the private network
sed -i "s/#listen_addresses = .*/listen_addresses = '$PRIVATE_IP'/g" /etc/postgresql/13/main/postgresql.conf

# Allow joining from the bhoos user without password to the database
echo "host    $DB_NAME         bhoos           $PRIVATE_IP/16           trust" >> /etc/postgresql/13/main/pg_hba.conf

# Enable service
systemctl enable postgresql

# Restart the service
systemctl restart postgresql
