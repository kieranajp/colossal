#!/bin/sh
## This script is called when backend changed.
set -e

# shellcheck disable=SC1091
[ -z "${HELPER_IMPORTED+x}" ] && . /usr/local/bin/helper.sh

echo "*** On change script ***"

# Execute Hook preChange if exists
execIfExists "/hooks/preChange" "* Custom preChange script"

echo "Run Conusl-template to generate template and reload if needed"
/usr/local/bin/consul-template \
    -consul-addr localhost:8500  \
    -once \
    -dedup \
    -template "/etc/haproxy.ctmpl:/etc/haproxy/haproxy.cfg:/usr/local/bin/haproxy-manage.sh reload"

# Manage drain of backends
# shellcheck disable=SC1091
[ -z "${HAPROXY_MANAGE_BACKENDS+x}" ] && /usr/local/bin/haproxy-backends.sh

# Execute Hook postChange if exists
execIfExists "/hooks/postChange" "* Custom postChange script"
