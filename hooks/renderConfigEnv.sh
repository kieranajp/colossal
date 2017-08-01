#!/bin/sh
## This script is called to run config render script then inject it into env
set -e

# shellcheck disable=SC1091
[ -z "${HELPER_IMPORTED+x}" ] && . /usr/local/bin/helper.sh

CONFIG_ENV_TEMPLATE="/hooks/configENV.ctmpl"
if [ -f "${CONFIG_ENV_TEMPLATE}" ]; then
    echo "* Render config template"

    /usr/local/bin/consul-template \
    -consul-addr localhost:8500  \
    -once \
    -dedup \
    -template "${CONFIG_ENV_TEMPLATE}:/etc/app_env:/usr/local/bin/setEnvFromFile.sh /etc/app_env"
fi
