#!/usr/bin/env python

import os
import socket
import signal

from flask import Flask
from flask import request
from redis import Redis

app = Flask(__name__)
bind_port = int(os.environ.get('APP_PORT', 8080))
redis_host = os.environ.get('REDIS_HOST', '127.0.0.1')
redis_port = os.environ.get('REDIS_PORT', '6379')
redis = Redis(host=redis_host, port=redis_port, socket_timeout=1)
hostname = socket.gethostname()


# Gracefully shutdown after serving active connection
def handle_term(signum, frame):
    print 'Shutting down...'
    func = request.environ.get('werkzeug.server.shutdown')
    if func is None:
        raise RuntimeError('Not running with the Werkzeug Server')
    func()


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
    # Register sigterm and call handle_term
    signal.signal(signal.SIGTERM, handle_term)
    app.run(host='0.0.0.0', port=bind_port, debug=False)
