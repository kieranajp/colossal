#!/bin/sh
## This script is called to run config render script then inject it into env
set -e

[ "${LOG_LEVEL}" = "debug" ] && set -x

CONFIG_ENV_TEMPLATE="/hooks/ConfigENV.ctmpl"
if [ -f "${CONFIG_ENV_TEMPLATE}" ]; then
    echo "* Render config template"

    /usr/local/bin/consul-template \
    -consul-addr "${CONSUL_ADDR}":8500  \
    -once \
    -dedup \
    -template "${CONFIG_ENV_TEMPLATE}:/etc/app_env:/usr/local/bin/setEnvFromFile.sh /etc/app_env"
    echo "RETURN $?"
fi

