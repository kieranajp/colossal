#!/bin/sh

echo "* Manage HAProxy backends"
# Create a temp dir
temp_dir="$(mktemp -d 2> /dev/null || mktemp -d -t 'mytmpdir')"

# Generate backend
/usr/local/bin/consul-template -consul-addr "localhost:8500" -once -dedup -template "/etc/haproxy-backends.ctmpl:${temp_dir}/setbackend.sh"

# Set backend to active/drain
sh "${temp_dir}/setbackend.sh"
