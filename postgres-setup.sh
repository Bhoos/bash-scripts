#!/bin/bash
export DB_USER = "bhoos"

apt -y update
apt -y upgrade

# Include postgreSQL repository
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | tee  /etc/apt/sources.list.d/pgdg.list
apt update

# Install postgresql v13
apt install -y postgresql-13

# Create user for application and accessing database
su - postgres --command "createuser $DB_USER"

# Extract the VPC private ip address (digital ocean)
export PRIVATE_IP=$(curl -s http://169.254.169.254/metadata/v1/interfaces/private/0/ipv4/address)

# Accept connection in the private network
sed -i "s/#listen_addresses = .*/listen_addresses = '$PRIVATE_IP'/g" /etc/postgresql/13/main/postgresql.conf

# Use tags to list out the databases
# all tags ending with `_db` is expected to be name of database
export TAGS=$(curl -s http://169.254.169.254/metadata/v1/tags/)

# Iterate through all the tags
for tag in $TAGS; do 
  # Check for the `_db` suffix
  if [[ "$tag" == *_db ]]; then
    # Create the database
    su - postgres --command "createdb $tag"

    # Allow joining from the DB_USER user without password to the database
    echo "host    $tag         $DB_USER           $PRIVATE_IP/16           trust" >> /etc/postgresql/13/main/pg_hba.conf
  fi
done

# Enable service
systemctl enable postgresql

# Restart the service
systemctl restart postgresql
