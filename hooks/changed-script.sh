#!/bin/sh
## This script is called when backend changed.
set -e

[ "${LOG_LEVEL}" = "debug" ] && set -x

echo "*** $0 ***"
if [ -z "${CONSUL+x}" ]; then
    # No Consul agent locally
    CONSUL_ADDR="${CONSUL}"
else
    CONSUL_ADDR=localhost
fi


CUSTOM_SCRIPT="/hooks/preChange"
if [ -x "${CUSTOM_SCRIPT}" ]; then
    echo "* Custom preChange script"
    ${CUSTOM_SCRIPT}
fi


# TODO: write a script that loops and checks backend that needs to be drained, disabled or goto maintaince mode


echo "Run Conusl-template to generate template and reload if needed"
/usr/local/bin/consul-template \
    -consul-addr ${CONSUL_ADDR}:8500  \
    -once \
    -dedup \
    -template "/etc/haproxy.ctmpl:/etc/haproxy/haproxy.cfg:/usr/local/bin/haproxy-manage.sh reload"

CUSTOM_SCRIPT="/hooks/postChange"
if [ -x "${CUSTOM_SCRIPT}" ]; then
    echo "* Custom postChange script"
    ${CUSTOM_SCRIPT}
fi
