#!/bin/sh
## Setup Nginx on alpine then run container pilot
set -e
DIR="$(cd "$(dirname "$0")" && pwd )"  # absolutized and normalized
apk add --update-cache curl bash openrc nginx

mkdir -p /run/nginx/
# Create config template
cat > /etc/nginx_template.conf.ctmpl <<EOL
server {
        listen 80 default_server;
        listen [::]:80 default_server;

        location /status {
            access_log off;
            return 200 "healthy\n";
        }
        location / {
            proxy_pass http://127.0.0.1:8889;
        }
}
EOL

# Create run config scripit
cat > /hooks/renderConfigFiles <<EOL
#!/bin/sh
/usr/local/bin/consul-template \
    -consul-addr localhost:8500  \
    -once \
    -dedup \
    -template "/etc/nginx_template.conf.ctmpl:/etc/nginx/conf.d/default.conf"

EOL

grep -q -F 'daemon off;' /etc/nginx/nginx.conf || echo 'daemon off;' >> /etc/nginx/nginx.conf

whoami
mkdir -p /x
echo "<html></html>" > /x/index.html

touch /var/log/containerpilot.log
if pgrep -x "/bin/containerpilot" > /dev/null
then
    echo "containerpilot"
else
    echo """#!/bin/sh
    exec /bin/containerpilot -config /etc/containerpilot.json5 >> /var/log/containerpilot.log 2>&1""" > /bin/start.sh
    chmod +x /bin/start.sh
    echo "Starting" | tee /var/log/containerpilot.log
    start-stop-daemon -b -m -p /tmp/containerpilot.pid -n container /bin/start.sh
    sleep 5
    ps aux
fi
