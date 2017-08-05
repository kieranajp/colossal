#!/bin/sh
## Setup Nginx on alpine then run container pilot
set -e
# Create config template


grep -q -F 'daemon off;' /etc/nginx/nginx.conf ||

whoami
mkdir -p /x
echo "<html></html>" > /x/index.html

# Needed for tests
apk add --update-cache curl bash openrc
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