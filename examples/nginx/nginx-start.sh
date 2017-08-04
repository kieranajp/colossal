#!/bin/sh
set -x

echo "checking nginx config"
nginx -T -c /etc/nginx/nginx.conf

echo "starting nginx"
exec nginx -g "daemon off;"
