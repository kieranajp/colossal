#!/bin/sh
set -e

echo "checking nginx config"
nginx -t -c /etc/nginx/nginx.conf
echo "..."

echo "starting nginx"
exec nginx -g "daemon off;"
