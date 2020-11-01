#!/bin/bash
apt update

# Install nginx
apt install -y nginx

# Enable nginx to start on boot
systemctl enable nginx

# Setup a reverse proxy server to the node app
unlink /etc/nginx/sites-enabled/default
echo "
server {
  listen 80;
  return 301 https://$server_name$request_uri;
}

server {
  listen 443 ssl;
  server_name bhoos.dev www.bhoos.dev;
  
  if ($host = www.bhoos.dev) {
    return 301 https://bhoos.dev$request_uri;
  }
  
  location / {
    proxy_pass http://localhost:3000;
  }
}" > /etc/nginx/sites-available/bhoos_dev
# Link the configuration
ln -s /etc/nginx/sites-available/bhoos_dev /etc/nginx/sites-enabled/bhoos_dev


# Setup Let's Encrypt
apt install -y python3-acme python3-certbot python3-mock python3-openssl python3-pkg-resources python3-pyparsing python3-zope.interface
apt install -y python3-certbot-nginx

# Install certificate
certbot --nginx -d bhoos.dev -d www.bhoos.dev --non-interactive --agree-tos -m devops@bhoos.com
