#!/bin/sh
## Setup Nginx on alpine then run container pilot
set -e
DIR="$(cd "$(dirname "$0")" && pwd )"  # absolutized and normalized
apk add --update-cache curl bash openrc python py-pip

echo """
flask==0.12
redis==2.10.5
""" > /requirements.txt

# Create the env template
cat > /hooks/configENV.ctmpl <<EOL
MYPILOT_ENV_CONF=CONTAINERPILOT
MYPILOT_PASSWORD={{ plugin "ssm" "-test-mode" "TEST_PARAM_VALUE" }}
EOL

cat > /app.py <<EOL
#!/usr/bin/env python
import os
import socket

from flask import Flask
from redis import Redis

app = Flask(__name__)
bind_port = int(os.environ.get('APP_PORT', 8080))
redis_host = os.environ.get('REDIS_HOST', '127.0.0.1')
redis_port = os.environ.get('REDIS_PORT', '6379')
redis = Redis(host=redis_host, port=redis_port, socket_timeout=1)
hostname = socket.gethostname()

@app.route('/')
def hello():
    try:
        redis.incr('hits')
        msg='Hello World! I am {} I have been seen {} times.'.format(hostname, redis.get('hits'))
    except:
        msg='Hello World! I am {} and redis "{}:{}" is down  :(.'.format(hostname, redis_host, redis_port)

    return msg

@app.route('/env')
def helloEnv():
    mypilot_conf = os.environ.get('MYPILOT_ENV_CONF', 'NOTDEFINED')
    msg='ENV={}'.format(mypilot_conf)

    return msg

@app.route('/env_encrypted')
def helloEncryptedEnv():
    mypilot_password = os.environ.get('MYPILOT_PASSWORD', 'NOTDEFINED')
    msg='ENV={}'.format(mypilot_password)

    return msg


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=bind_port, debug=False)
EOL

pip install -r /requirements.txt
chmod +x /app.py

touch /var/containerpilot.log
if pgrep -x "/bin/containerpilot" > /dev/null
then
    echo "containerpilot"
else
    echo """#!/bin/sh
    exec /bin/containerpilot -config /etc/containerpilot.json5 >> /var/log/containerpilot.log 2>&1""" > /bin/start.sh
    chmod +x /bin/start.sh
    echo "Starting" | tee /var/containerpilot.log
    start-stop-daemon -b -m -p /tmp/containerpilot.pid -n container /bin/start.sh
    sleep 5
    ps aux
fi
