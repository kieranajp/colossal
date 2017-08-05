#!/bin/sh
set -e

## Hooks
cat > /hook-test.sh <<EOL
#!/bin/sh
echo "${0} running"
EOL

chmod +x /hook-test.sh
## Link hooks
ln -sf /hook-test.sh /hooks/preStart
ln -sf /hook-test.sh /hooks/renderConfigFiles
ln -sf /hook-test.sh /hooks/preChange
ln -sf /hook-test.sh /hooks/postChange
ln -sf /hook-test.sh /hooks/preStop
ln -sf /hook-test.sh /hooks/postStop

cat > /hook-test.sh <<EOL
#!/bin/sh
echo "Hook \${0} running"
EOL

cat >  /hooks/configENV.ctmpl <<EOL
COLOSSAL=SOMETHONING
EOL

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

set +x
APP_PID="$(pgrep -f nc)"
set -x
if [ -n "${APP_PID}" ] ; then
    echo "* sleeping for 10"
    sleep 10
    echo "* Killing Application"
    kill -9 "${APP_PID}"
else
    echo "No App running"
fi
