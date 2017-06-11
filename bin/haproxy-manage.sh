#!/bin/sh
set -e
#set the LOG_LEVEL=debug env variable to turn on debugging
[ "${LOG_LEVEL}" = "debug" ] && set -x

HA_PROXY_CONFIG="/etc/haproxy/haproxy.cfg"
HA_PROXY_PID="/var/run/haproxy.pid"

_ha_proxy_check_config(){
    echo "Checking HAproxy configuration file"
    haproxy -c -f "${HA_PROXY_CONFIG}" 2>&1
}

_ha_proxy_start(){
  sf=""
  # Check if we need to replace our haproxy by passing -sf
  if [ -f ${HA_PROXY_PID} ]; then
    sf="-sf $(cat ${HA_PROXY_PID})"
  fi
  /usr/sbin/haproxy -D -p ${HA_PROXY_PID} -f ${HA_PROXY_CONFIG} ${sf}
  sleep 2
}

start(){
    echo "HAproxy start: Starting: HAProxy"
    _ha_proxy_start
}

reload(){
    echo "HAproxy realod: Pre-reload pid(s) $(pidof haproxy)"
    _ha_proxy_check_config

    ## Reload
    echo "HAproxy realod: Reloading haproxy"
    _ha_proxy_start

    echo "HAproxy realod: Post-reload pid(s) $(pidof haproxy)"
    echo "HAproxy realod: reloaded successfully"
}

# Call first argument passed
if [ ! -z "$1" ]; then
    ${1}
else
    echo "${0} requires an argument."
    exit 1
fi
